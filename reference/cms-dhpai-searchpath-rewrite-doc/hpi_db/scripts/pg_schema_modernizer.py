#!/usr/bin/env python3
"""
PostgreSQL Schema Modernization Tool

This tool replaces SET search_path statements with explicit schema prefixes
for all database objects (tables, views, procedures, triggers, indexes, sequences)
in PostgreSQL SQL files.

Features:
- Removes SET search_path statements
- Adds explicit schema prefixes (download. or hkpmi.) to table references
- Handles schema conflicts with priority based on search_path
- Generates comprehensive reports
- Preserves temp tables and column names

Usage:
    python pg_schema_modernizer.py --input-dir /path/to/hkpmi_db --output-dir /path/to/output
"""

import os
import re
import argparse
import logging
from pathlib import Path
from typing import Dict, Set, List, Tuple, Optional
from dataclasses import dataclass
import sqlglot
from sqlglot import expressions as exp
from sqlglot.dialects import postgres


@dataclass
class SchemaInfo:
    """Information about a schema and its objects."""
    name: str
    tables: Set[str]
    views: Set[str]
    procedures: Set[str]
    functions: Set[str]
    triggers: Set[str]
    indexes: Set[str]
    sequences: Set[str]


@dataclass
class ModernizationResult:
    """Result of modernizing a single file."""
    file_path: str
    original_search_path: Optional[str]
    tables_modified: int
    conflicts_found: List[str]
    success: bool
    error_message: Optional[str] = None


class PostgreSQLSchemaModernizer:
    """Main class for PostgreSQL schema modernization."""

    def __init__(self, input_dir: str, output_dir: str = None):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir) if output_dir else self.input_dir
        self.schemas: Dict[str, SchemaInfo] = {}
        self.conflicts: Dict[str, List[str]] = {}  # object_name -> [schema1, schema2]

        # Setup logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger(__name__)

    def analyze_schemas(self) -> None:
        """Analyze the schema structure and identify all database objects."""
        self.logger.info("Analyzing schema structure...")

        # Analyze hkpmi schema
        hkpmi_dir = self.input_dir / "hkpmi"
        if hkpmi_dir.exists():
            self._analyze_schema_directory("hkpmi", hkpmi_dir)

        # Analyze hpi schema
        hpi_dir = self.input_dir / "hpi"
        if hpi_dir.exists():
            self._analyze_schema_directory("hpi", hpi_dir)

        # Identify conflicts
        self._identify_conflicts()

        self.logger.info(f"Found {len(self.schemas)} schemas with database objects")
        for schema_name, schema_info in self.schemas.items():
            total_objects = (len(schema_info.tables) + len(schema_info.views) +
                           len(schema_info.procedures) + len(schema_info.functions) +
                           len(schema_info.triggers) + len(schema_info.indexes) +
                           len(schema_info.sequences))
            self.logger.info(f"  {schema_name}: {total_objects} objects")

        if self.conflicts:
            self.logger.warning(f"Found {len(self.conflicts)} object name conflicts")
            for obj, schemas in self.conflicts.items():
                self.logger.warning(f"  {obj}: exists in {', '.join(schemas)}")

    def _analyze_schema_directory(self, schema_name: str, schema_dir: Path) -> None:
        """Analyze a schema directory for database objects."""
        schema_info = SchemaInfo(
            name=schema_name,
            tables=set(),
            views=set(),
            procedures=set(),
            functions=set(),
            triggers=set(),
            indexes=set(),
            sequences=set()
        )

        # Analyze table directory
        table_dir = schema_dir / "table"
        if table_dir.exists():
            for sql_file in table_dir.glob("*.sql"):
                table_name = sql_file.stem.lower()  # Store in lowercase for case-insensitive matching
                schema_info.tables.add(table_name)

        # Analyze view directory
        view_dir = schema_dir / "view"
        if view_dir.exists():
            for sql_file in view_dir.glob("*.sql"):
                view_name = sql_file.stem.lower()  # Store in lowercase for case-insensitive matching
                schema_info.views.add(view_name)

        # Analyze function-n-procedure directory
        func_dir = schema_dir / "function-n-procedure"
        if func_dir.exists():
            for sql_file in func_dir.glob("*.sql"):
                # Read first few lines to determine if it's a function or procedure
                try:
                    with open(sql_file, 'r', encoding='utf-8') as f:
                        content = f.read(1000).upper()
                        obj_name = sql_file.stem.lower()  # Store in lowercase for case-insensitive matching
                        if 'CREATE OR REPLACE FUNCTION' in content:
                            schema_info.functions.add(obj_name)
                        elif 'CREATE OR REPLACE PROCEDURE' in content:
                            schema_info.procedures.add(obj_name)
                        else:
                            # If we can't determine, add to both (will be resolved by content analysis)
                            schema_info.functions.add(obj_name)
                            schema_info.procedures.add(obj_name)
                except Exception as e:
                    self.logger.warning(f"Error reading {sql_file}: {e}")

        # Analyze trigger directory
        trigger_dir = schema_dir / "trigger"
        if trigger_dir.exists():
            for sql_file in trigger_dir.glob("*.sql"):
                trigger_name = sql_file.stem.lower()  # Store in lowercase for case-insensitive matching
                schema_info.triggers.add(trigger_name)

        self.schemas[schema_name] = schema_info

    def _identify_conflicts(self) -> None:
        """Identify objects that exist in multiple schemas."""
        all_objects = {}
        for schema_name, schema_info in self.schemas.items():
            for obj_type, obj_set in [
                ('table', schema_info.tables),
                ('view', schema_info.views),
                ('procedure', schema_info.procedures),
                ('function', schema_info.functions),
                ('trigger', schema_info.triggers),
                ('index', schema_info.indexes),
                ('sequence', schema_info.sequences)
            ]:
                for obj_name in obj_set:
                    if obj_name not in all_objects:
                        all_objects[obj_name] = []
                    all_objects[obj_name].append(schema_name)

        for obj_name, schemas in all_objects.items():
            if len(schemas) > 1:
                self.conflicts[obj_name] = schemas

    def modernize_files(self) -> List[ModernizationResult]:
        """Modernize all SQL files in the input directory."""
        results = []

        # Process all SQL files
        for sql_file in self.input_dir.rglob("*.sql"):
            result = self._modernize_file(sql_file)
            results.append(result)

        return results

    def _modernize_file(self, file_path: Path) -> ModernizationResult:
        """Modernize a single SQL file."""
        print(f"DEBUG: Processing file: {file_path}")
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()

            # Determine target schema based on file path
            target_schema = self._determine_target_schema(file_path)

            # Parse and modernize the SQL
            modernized_content, search_path, tables_modified, conflicts = self._modernize_sql_content(
                original_content, target_schema
            )

            # Write back if changes were made
            if modernized_content != original_content:
                output_path = self.output_dir / file_path.relative_to(self.input_dir)
                output_path.parent.mkdir(parents=True, exist_ok=True)
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(modernized_content)

            return ModernizationResult(
                file_path=str(file_path),
                original_search_path=search_path,
                tables_modified=tables_modified,
                conflicts_found=conflicts,
                success=True
            )

        except Exception as e:
            self.logger.error(f"Error modernizing {file_path}: {e}")
            return ModernizationResult(
                file_path=str(file_path),
                original_search_path=None,
                tables_modified=0,
                conflicts_found=[],
                success=False,
                error_message=str(e)
            )

    def _determine_target_schema(self, file_path: Path) -> str:
        """Determine the target schema for a file based on its path."""
        path_str = str(file_path)
        if '/hkpmi/' in path_str or '\\hkpmi\\' in path_str:
            return 'hkpmi'
        elif '/hpi/' in path_str or '\\hpi\\' in path_str:
            return 'hpi'
        elif '/download/' in path_str or '\\download\\' in path_str:
            return 'download'
        else:
            return 'download'  # Default fallback

    def _modernize_sql_content(self, content: str, target_schema: str) -> Tuple[str, Optional[str], int, List[str]]:
        """Modernize SQL content by removing search_path and adding prefixes."""
        original_content = content
        search_path_found = None
        tables_modified = 0
        conflicts_found = []

        # Remove SET search_path statements and extract the schema
        content, search_path_found = self._remove_search_path_statements(content)

        # If search_path was found, use it to determine priority for conflicts
        priority_schema = target_schema
        if search_path_found:
            # Extract first schema from search_path (e.g., "hkpmi, public" -> "hkpmi")
            match = re.search(r'set\s+search_path\s+to\s+([a-zA-Z_][a-zA-Z0-9_]*),?', content, re.IGNORECASE)
            if match:
                priority_schema = match.group(1).lower()

        # Add schema prefixes to table references
        content, tables_modified, conflicts_found = self._add_schema_prefixes(
            content, priority_schema
        )

        return content, search_path_found, tables_modified, conflicts_found

    def _remove_search_path_statements(self, content: str) -> Tuple[str, Optional[str]]:
        """Remove SET search_path statements from SQL content."""
        search_path_pattern = r'^\s*SET\s+(?:LOCAL\s+)?search_path\s+TO\s+[^;]+;'
        search_path_found = None

        def replace_match(match):
            nonlocal search_path_found
            search_path_found = match.group(0).strip()
            return ''

        content = re.sub(search_path_pattern, replace_match, content, flags=re.MULTILINE | re.IGNORECASE)

        # Also handle RESET search_path
        reset_pattern = r'^\s*RESET\s+search_path\s*;'
        content = re.sub(reset_pattern, '', content, flags=re.MULTILINE | re.IGNORECASE)

        return content, search_path_found

    def _add_schema_prefixes(self, content: str, priority_schema: str) -> Tuple[str, int, List[str]]:
        """Add schema prefixes to table references in SQL content."""
        tables_modified = 0
        conflicts_found = []

        # First, try to use SQLGlot for parsing
        try:
            # Split content into statements (basic approach)
            statements = []
            current_statement = []
            in_function = False
            in_dollar_quote = False
            dollar_tag = None

            lines = content.split('\n')
            for line in lines:
                stripped = line.strip()

                # Track dollar quoting
                if '$' in stripped:
                    dollar_matches = re.findall(r'\$(\w*)\$', stripped)
                    for tag in dollar_matches:
                        if not in_dollar_quote:
                            in_dollar_quote = True
                            dollar_tag = tag
                        elif tag == dollar_tag:
                            in_dollar_quote = False
                            dollar_tag = None

                # Track function/procedure blocks
                if re.search(r'\bCREATE\s+(OR\s+REPLACE\s+)?(?:FUNCTION|PROCEDURE)\b', stripped, re.IGNORECASE):
                    in_function = True
                elif stripped.startswith('$$') or (dollar_tag and f'${dollar_tag}$' in stripped):
                    in_function = False

                current_statement.append(line)

                # End of statement detection
                if not in_function and not in_dollar_quote and stripped.endswith(';'):
                    statements.append('\n'.join(current_statement))
                    current_statement = []

            # Add remaining content
            if current_statement:
                statements.append('\n'.join(current_statement))

            # Process each statement
            transformed_statements = []
            for stmt in statements:
                if stmt.strip():
                    transformed, mods, conflicts = self._process_single_statement(stmt, priority_schema)
                    tables_modified += mods
                    conflicts_found.extend(conflicts)
                    transformed_statements.append(transformed)

            result = '\n'.join(transformed_statements)

        except Exception as e:
            self.logger.warning(f"Advanced parsing failed, falling back to regex: {e}")
            # Fallback to regex-based transformation
            result, tables_modified, conflicts_found = self._regex_add_prefixes(
                content, priority_schema
            )

        return result, tables_modified, conflicts_found

    def _process_single_statement(self, statement: str, priority_schema: str) -> Tuple[str, int, List[str]]:
        """Process a single SQL statement to add schema prefixes."""
        tables_modified = 0
        conflicts_found = []

        try:
            # Try to parse with SQLGlot
            parsed = sqlglot.parse(statement, dialect=postgres.Postgres)
            if parsed and not any(isinstance(stmt, exp.Command) for stmt in parsed):
                # Successfully parsed and no Command expressions (which indicate failed parsing)
                transformed = []
                for stmt in parsed:
                    transformed_stmt, mods, conflicts = self._transform_statement(stmt, priority_schema)
                    tables_modified += mods
                    conflicts_found.extend(conflicts)
                    transformed.append(transformed_stmt)

                result = '\n'.join(sqlglot.transpile(transformed_stmt, read=postgres.Postgres, write=postgres.Postgres)[0]
                                 for transformed_stmt in transformed)
            else:
                # Fallback to regex if parsing failed or resulted in Command expressions
                result, tables_modified, conflicts_found = self._regex_add_prefixes(
                    statement, priority_schema
                )
        except Exception:
            # Fallback to regex
            result, tables_modified, conflicts_found = self._regex_add_prefixes(
                statement, priority_schema
            )

        return result, tables_modified, conflicts_found

    def _transform_statement(self, statement: exp.Expression, priority_schema: str) -> Tuple[exp.Expression, int, List[str]]:
        """Transform a SQL statement to add schema prefixes."""
        tables_modified = 0
        conflicts_found = []

        print(f"DEBUG: _transform_statement called with statement type: {type(statement)}")

        # Find all table references in the statement
        for table in statement.find_all(exp.Table):
            original_name = table.name

            # Skip if already has schema prefix
            if table.db:
                continue

            # Determine which schema to use (case-insensitive)
            target_schema = self._resolve_schema_for_table(original_name, priority_schema)

            if target_schema:
                # Add schema prefix
                table.set("db", exp.to_identifier(target_schema))
                tables_modified += 1

                # Check for conflicts (case-insensitive)
                if original_name.lower() in [c.lower() for c in self.conflicts.keys()]:
                    conflicts_found.append(f"{original_name} -> {target_schema}")

        # Find all qualified column references (Table.Column) and add schema prefixes
        print(f"DEBUG: Looking for qualified columns in statement")
        for column in statement.find_all(exp.Column):
            print(f"DEBUG: Found column: {column}, table: {column.table}, db: {column.db}")
            # Only process qualified columns (those with a table reference)
            if column.table and not column.db:
                table_name = column.table
                column_name = column.name

                print(f"DEBUG: Processing qualified column: {table_name}.{column_name}")

                # Skip if table already has schema prefix
                if '.' in table_name:
                    continue

                # Skip temp tables
                if table_name.lower().startswith(('temp', 'tmp')):
                    continue

                # Determine which schema to use for the table
                target_schema = self._resolve_schema_for_table(table_name, priority_schema)

                if target_schema:
                    print(f"DEBUG: Adding schema prefix {target_schema} to {table_name}.{column_name}")
                    # Add schema prefix to the table part of the column reference
                    column.set("table", f"{target_schema}.{table_name}")
                    tables_modified += 1

                    # Check for conflicts (case-insensitive)
                    if table_name.lower() in [c.lower() for c in self.conflicts.keys()]:
                        conflicts_found.append(f"{table_name}.{column_name} -> {target_schema}")

        # Find all function/procedure calls
        for func_call in statement.find_all(exp.Anonymous):
            if func_call.this and func_call.this.upper() in ('CALL', 'EXEC'):
                # This is a CALL or EXEC statement
                if func_call.expressions:
                    func_expr = func_call.expressions[0]
                    if isinstance(func_expr, exp.Column) and not func_expr.table:
                        # Function name without schema
                        func_name = func_expr.name
                        target_schema = self._resolve_schema_for_table(func_name, priority_schema)
                        if target_schema:
                            func_expr.set("table", exp.to_identifier(target_schema))
                            tables_modified += 1
                            if func_name.lower() in [c.lower() for c in self.conflicts.keys()]:
                                conflicts_found.append(f"{func_name} -> {target_schema}")

        return statement, tables_modified, conflicts_found

    def _resolve_schema_for_table(self, table_name: str, priority_schema: str) -> Optional[str]:
        """Resolve which schema to use for a table reference."""
        table_name_lower = table_name.lower()

        print(f"DEBUG: _resolve_schema_for_table called with {table_name}, priority {priority_schema}")

        # Check if table exists in priority schema
        if priority_schema in self.schemas:
            schema_info = self.schemas[priority_schema]
            print(f"DEBUG: priority schema {priority_schema} tables: {len(schema_info.tables)} items, has {table_name_lower}: {table_name_lower in schema_info.tables}")
            if (table_name_lower in schema_info.tables or
                table_name_lower in schema_info.views or
                table_name_lower in schema_info.procedures or
                table_name_lower in schema_info.functions):
                print(f"DEBUG: found {table_name_lower} in priority schema {priority_schema}")
                return priority_schema

        # Check if table exists in any schema
        print(f"DEBUG: checking all schemas")
        for schema_name, schema_info in self.schemas.items():
            print(f"DEBUG: checking schema {schema_name}, tables: {len(schema_info.tables)} items")
            if (table_name_lower in schema_info.tables or
                table_name_lower in schema_info.views or
                table_name_lower in schema_info.procedures or
                table_name_lower in schema_info.functions):
                print(f"DEBUG: found {table_name_lower} in schema {schema_name}")
                return schema_name

        # Table not found in any schema
        print(f"DEBUG: {table_name_lower} not found in any schema")
        return None

    def _regex_add_prefixes(self, content: str, priority_schema: str) -> Tuple[str, int, List[str]]:
        """Fallback regex-based schema prefix addition."""
        print(f"DEBUG: _regex_add_prefixes called with priority_schema: {priority_schema}")
        print(f"DEBUG: Content length: {len(content)}")
        tables_modified = 0
        conflicts_found = []

        # Pattern to match table references in various SQL clauses
        # Enhanced patterns to handle more complex cases
        patterns = [
            # FROM clauses with multiple tables (handles aliases and commas)
            r'\bFROM\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*(?:\s*,\s*[a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)*)',
            # JOIN clauses
            r'\b(?:INNER\s+|LEFT\s+|RIGHT\s+|FULL\s+|CROSS\s+)?JOIN\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # INSERT INTO
            r'\bINSERT\s+INTO\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # UPDATE
            r'\bUPDATE\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # DELETE FROM
            r'\bDELETE\s+FROM\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # CALL statements for procedures/functions
            r'\bCALL\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s*\([^)]*\))?)',
            # EXEC statements
            r'\bEXEC\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # ALTER statements
            r'\bALTER\s+(?:TABLE|VIEW|FUNCTION|PROCEDURE|TRIGGER|INDEX|SEQUENCE)\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # DROP statements
            r'\bDROP\s+(?:TABLE|VIEW|FUNCTION|PROCEDURE|TRIGGER|INDEX|SEQUENCE)\s+(?:IF\s+EXISTS\s+)?([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
            # CREATE statements
            r'\bCREATE\s+(?:OR\s+REPLACE\s+)?(?:TABLE|VIEW|FUNCTION|PROCEDURE|TRIGGER|INDEX|SEQUENCE)\s+([a-zA-Z_$][a-zA-Z0-9_$]*(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*)',
        ]

        def process_table_list(table_list_str: str) -> str:
            """Process a comma-separated list of tables with optional aliases."""
            nonlocal tables_modified, conflicts_found

            # Split by commas, but be careful with function calls that have parentheses
            if '(' in table_list_str and table_list_str.strip().endswith(')'):
                # This is likely a function call, process the function name only
                func_match = re.match(r'^([a-zA-Z_$][a-zA-Z0-9_$]*)\s*\(', table_list_str.strip())
                if func_match:
                    func_name = func_match.group(1)
                    schema = self._resolve_schema_for_table(func_name, priority_schema)
                    if schema and not table_list_str.startswith(f"{schema}."):
                        tables_modified += 1
                        if func_name.lower() in [c.lower() for c in self.conflicts.keys()]:
                            conflicts_found.append(f"{func_name} -> {schema}")
                        return table_list_str.replace(func_name, f"{schema}.{func_name}", 1)
                return table_list_str

            # Split by commas for table lists
            tables = [t.strip() for t in table_list_str.split(',')]
            processed_tables = []

            for table_spec in tables:
                # Extract table name (first word, handling aliases)
                table_match = re.match(r'^([a-zA-Z_$][a-zA-Z0-9_$]*)(?:\s+[a-zA-Z_][a-zA-Z0-9_]*)*', table_spec)
                if table_match:
                    table_name = table_match.group(1)

                    # Skip if already has schema prefix or is a temp table
                    if '.' in table_name or table_name.lower().startswith(('temp', 'tmp')):
                        processed_tables.append(table_spec)
                        continue

                    # Resolve schema
                    schema = self._resolve_schema_for_table(table_name, priority_schema)
                    if schema:
                        tables_modified += 1
                        if table_name.lower() in [c.lower() for c in self.conflicts.keys()]:
                            conflicts_found.append(f"{table_name} -> {schema}")
                        # Replace the table name with schema-qualified name
                        processed_spec = table_spec.replace(table_name, f"{schema}.{table_name}", 1)
                        processed_tables.append(processed_spec)
                    else:
                        processed_tables.append(table_spec)
                else:
                    processed_tables.append(table_spec)

            return ', '.join(processed_tables)

        for pattern in patterns:
            def replace_match(match):
                table_list = match.group(1)
                processed = process_table_list(table_list)
                return match.group(0).replace(table_list, processed)

            content = re.sub(pattern, replace_match, content, flags=re.IGNORECASE)

        # Process qualified column references (Table.Column) throughout the SQL
        qualified_column_pattern = r'\b([a-zA-Z_$][a-zA-Z0-9_$]*)\.([a-zA-Z_$][a-zA-Z0-9_$]*)\b'
        
        def process_qualified_column(match):
            nonlocal tables_modified, conflicts_found
            table_part = match.group(1)
            column_part = match.group(2)
            
            print(f"DEBUG: Processing qualified column regex: {table_part}.{column_part}")
            
            # Skip if table part already has schema prefix (contains dot)
            if '.' in table_part:
                print(f"DEBUG: Skipping already qualified: {table_part}.{column_part}")
                return match.group(0)
            
            # Skip if this looks like a schema-qualified reference (table_part is a known schema)
            if table_part.lower() in [s.lower() for s in self.schemas.keys()]:
                print(f"DEBUG: Skipping schema reference: {table_part}.{column_part}")
                return match.group(0)
            
            # Skip temp tables
            if table_part.lower().startswith(('temp', 'tmp')):
                print(f"DEBUG: Skipping temp table: {table_part}.{column_part}")
                return match.group(0)
            
            # Resolve schema for the table
            schema = self._resolve_schema_for_table(table_part, priority_schema)
            if schema:
                print(f"DEBUG: Adding schema prefix via regex: {schema}.{table_part}.{column_part}")
                tables_modified += 1
                if table_part.lower() in [c.lower() for c in self.conflicts.keys()]:
                    conflicts_found.append(f"{table_part}.{column_part} -> {schema}")
                return f"{schema}.{table_part}.{column_part}"
            
            print(f"DEBUG: No schema found for table: {table_part}")
            return match.group(0)
        
        content = re.sub(qualified_column_pattern, process_qualified_column, content)

        return content, tables_modified, conflicts_found

    def generate_report(self, results: List[ModernizationResult]) -> str:
        """Generate a comprehensive report of the modernization process."""
        report = []
        report.append("# PostgreSQL Schema Modernization Report")
        report.append("")

        # Summary statistics
        total_files = len(results)
        successful_files = sum(1 for r in results if r.success)
        total_tables_modified = sum(r.tables_modified for r in results if r.success)
        total_conflicts = sum(len(r.conflicts_found) for r in results if r.success)

        report.append("## Summary")
        report.append(f"- Total files processed: {total_files}")
        report.append(f"- Successfully modernized: {successful_files}")
        report.append(f"- Failed: {total_files - successful_files}")
        report.append(f"- Total table references modified: {total_tables_modified}")
        report.append(f"- Schema conflicts resolved: {total_conflicts}")
        report.append("")

        # Schema information
        report.append("## Schema Analysis")
        for schema_name, schema_info in self.schemas.items():
            report.append(f"### {schema_name.upper()} Schema")
            report.append(f"- Tables: {len(schema_info.tables)}")
            report.append(f"- Views: {len(schema_info.views)}")
            report.append(f"- Procedures: {len(schema_info.procedures)}")
            report.append(f"- Functions: {len(schema_info.functions)}")
            report.append(f"- Triggers: {len(schema_info.triggers)}")
            report.append(f"- Indexes: {len(schema_info.indexes)}")
            report.append(f"- Sequences: {len(schema_info.sequences)}")
            report.append("")

        # Conflicts
        if self.conflicts:
            report.append("## Schema Conflicts")
            for obj_name, schemas in self.conflicts.items():
                report.append(f"- `{obj_name}`: exists in {', '.join(schemas)}")
            report.append("")

        # File details
        report.append("## File Processing Details")
        for result in results:
            status = "✅" if result.success else "❌"
            report.append(f"### {status} {result.file_path}")
            if result.original_search_path:
                report.append(f"- Removed search_path: `{result.original_search_path}`")
            if result.tables_modified > 0:
                report.append(f"- Tables modified: {result.tables_modified}")
            if result.conflicts_found:
                report.append(f"- Conflicts resolved: {', '.join(result.conflicts_found)}")
            if not result.success and result.error_message:
                report.append(f"- Error: {result.error_message}")
            report.append("")

        return '\n'.join(report)


def main():
    parser = argparse.ArgumentParser(description="PostgreSQL Schema Modernization Tool")
    parser.add_argument("--input-dir", required=True, help="Input directory containing hkpmi_db")
    parser.add_argument("--output-dir", help="Output directory (defaults to input-dir)")
    parser.add_argument("--report-file", default="modernization_report.md", help="Report file name")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging")

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Initialize modernizer
    modernizer = PostgreSQLSchemaModernizer(args.input_dir, args.output_dir)

    # Analyze schemas
    modernizer.analyze_schemas()

    # Modernize files
    results = modernizer.modernize_files()

    # Generate report
    report = modernizer.generate_report(results)

    # Write report
    report_path = Path(args.output_dir or args.input_dir) / args.report_file
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write(report)

    print(f"Modernization complete! Report written to: {report_path}")


if __name__ == "__main__":
    main()