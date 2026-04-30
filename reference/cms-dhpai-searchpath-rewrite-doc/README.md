# PAS Schema Rewrite Tool v1.0

A comprehensive PostgreSQL schema modernization toolkit for HPI and HKPMI database systems. This tool automates the modernization of legacy PostgreSQL SQL files by replacing implicit schema references with explicit schema prefixes, ensuring compatibility with modern database standards and eliminating search_path dependencies.

## Quick Start Guide

### Prerequisites

- **VS Code** with **GitHub Copilot** extension
- **Copilot model**: Recommended to use **Grok Code Fast 1** or **Claude Sonnet 4** for best performance

### Simple 3-Step Process

1. **Clone and Open in VS Code**

   ```bash
   git clone https://hagithub.home/tcw840/dhpai-pas-schema-rewriter-doc.git
   code .
   ```

2. **Add Script to Copilot Chat**
   - Open VS Code
   - Open Copilot Chat panel
   - Add the file `pg_schema_modernizer.py` to chat using the "Add file to chat" feature

3. **Run with Simple Prompt**
   For HPI database processing:

   ```
   run the python for hpi_db
   ```

   For HKPMI database processing:

   ```
   run the python for hkpmi_db
   ```

Copilot will automatically handle the entire modernization process.

## What This Tool Does

- **Eliminates search_path dependencies** by removing `SET search_path` and `RESET search_path` statements
- **Adds explicit schema prefixes** to all database object references (tables, views, procedures, functions, triggers, indexes, sequences)
- **Generates detailed reports** documenting all changes and potential issues

## Schema-Specific Information

### HKPMI Database (hkpmi_db)

- **Primary schemas**: `download`, `hkpmi`
- **Key objects**: Patient data management, transaction logging, upload controls

### HPI Database (hpi_db)

- **Primary schemas**: `hkpmi`, `hpi`
- **Key objects**: Patient episodes, discharge transfers, hospital uploads

## Development Prompts

### Schema Rewrite Requirements

**Context**: You are enhancing the Python-based conversion tool that processes SQL files under the hpi_db folder. The context labeled "context 7" describes the PostgreSQL schema. In addition to the earlier requirements, address the following issues observed in the current output:

1. **Case-Insensitive Object Matching**: Ensure case-insensitive matching of object names so that views like `hpi.case_view` are detected even when referenced as `Case_view`. Example: `hosp_adm_disc_by_ward.sql` should convert `FROM Case_view` to `FROM hpi.case_view`.

2. **Comprehensive Schema Prefixing**: Ensure all tables, views, stored procedures, functions, triggers, indexes, and sequences receive the correct schema prefix when they are matched, regardless of capitalization. Example: `cpi_cancel_discharged.sql` must convert `FROM HN_case_detail` to `FROM hpi.hn_case_detail`.

3. **Multi-Table Alias Lists**: Handle alias lists with multiple tables. Example: `cms_dt_get_iso_detail.sql` contains `FROM hpi.cpi_patient_hospital_data h, cpi_case c, cpi_patient p`. Every object in such lists must be qualified (`FROM hpi.cpi_patient_hospital_data h, {schema}.cpi_case c, {schema}.cpi_patient p`), respecting search-path precedence and conflict rules.

4. **Function/Procedure Call Qualification**: Qualify all function/procedure calls. Example: `web_cpi_address_search_2.sql` has `CALL cpi_address_build_short_key`. This must become `CALL {schema}.cpi_address_build_short_key`.

**Core Requirements (Carried Forward)**:

- Remove or replace all `SET search_path` statements by adding explicit schema prefixes.
- Determine schema prefixes by matching objects across the `hpi` and `hkpmi` schemas, respecting declared search paths when conflicts arise.
- Insert a comment at the top of the file when conflicting object names are detected, reminding reviewers.
- Do not prefix temporary tables (e.g., `CREATE TEMP TABLE`).
- Never prefix column names or non-object tokens.
- Handle every SQL statement type that may reference objects (SELECT, INSERT, UPDATE, DELETE, JOIN, CALL, EXEC, ALTER, DROP, CREATE, etc.).
- Produce an overall result report summarizing processed files, prefixes added, conflicts, and any skipped files.
- Preserve formatting where possible.

**Implementation Notes**:

- Python scripts must scan the `hpi_db` folder recursively, parse SQL content thoroughly (including multi-line statements, aliases, quoted identifiers, PostgreSQL-specific constructs), remove / replace `search_path`, and insert schema prefixes.
- Add logic to detect case-insensitive matches and apply canonical schema-qualified names.
- Update conflict detection to work regardless of capitalization.
- Ensure alias lists and CALL statements receive prefixes.
- Maintain unit tests covering all transformations (case-insensitive matching, multi-table lists, procedure calls, temporary tables, conflict handling, etc.).
- Ensure the final output includes updated SQL files with prefixes and comments where needed, plus the overall report.

## Related Documentation

- [HKPMI Schema README](hkpmi_db/scripts/README.md)
- [HPI Schema README](hpi_db/scripts/README.md)
- [SQLGlot Documentation](https://sqlglot.com/)
- [PostgreSQL Schema Search Path](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH)
