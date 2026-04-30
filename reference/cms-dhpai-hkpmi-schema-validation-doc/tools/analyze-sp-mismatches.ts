#!/usr/bin/env node

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

interface ColumnInfo {
	column_name: string;
	data_type: string;
	character_maximum_length?: number;
}

interface TableInfo {
	table_name: string;
	columns: ColumnInfo[];
}

interface SchemaInfo {
	[tableName: string]: TableInfo;
}

interface MismatchRecord {
	filename: string;
	table_name: string;
	column_name: string;
	data_type: string;
	possible_data_type: string;
	source_files_tables: string;
	mismatch_type: string;
}

interface TempTableColumn {
	name: string;
	type: string;
	length?: number;
}

interface TempTable {
	name: string;
	columns: TempTableColumn[];
}

interface TableReference {
	schema: string;
	table: string;
	alias: string;
}

class SPMismatchAnalyzer {
	private hkpmiSchema: SchemaInfo = {};
	private hpiSchema: SchemaInfo = {};
	private spContent: string = "";
	private spFilename: string = "";

	constructor(spFilePath: string) {
		this.spFilename = path.basename(spFilePath);
		this.loadSchemas();
		this.loadSPFile(spFilePath);
	}

	private loadSchemas(): void {
		try {
			// Load HKPMI schema
			const hkpmiPath = path.join(
				__dirname,
				"..",
				"data",
				"column-types-hkpmi.json",
			);
			const hkpmiArray = JSON.parse(fs.readFileSync(hkpmiPath, "utf8"));

			// Convert array structure to table-keyed object
			this.hkpmiSchema = {};
			for (const fileData of hkpmiArray) {
				for (const table of fileData.tables) {
					this.hkpmiSchema[table.name] = {
						table_name: table.name,
						columns: table.properties.map((prop: any) => ({
							column_name: prop.name,
							data_type: prop.type.includes("varchar")
								? "character varying"
								: prop.type,
							character_maximum_length: this.extractLength(prop.type),
						})),
					};
				}
			}

			// Load HPI schema
			const hpiPath = path.join(
				__dirname,
				"..",
				"data",
				"column-types-hpi.json",
			);
			const hpiArray = JSON.parse(fs.readFileSync(hpiPath, "utf8"));

			// Convert array structure to table-keyed object
			this.hpiSchema = {};
			for (const fileData of hpiArray) {
				for (const table of fileData.tables) {
					this.hpiSchema[table.name] = {
						table_name: table.name,
						columns: table.properties.map((prop: any) => ({
							column_name: prop.name,
							data_type: prop.type.includes("varchar")
								? "character varying"
								: prop.type,
							character_maximum_length: this.extractLength(prop.type),
						})),
					};
				}
			}

			console.log(`✅ Loaded schemas:`);
			console.log(`   - HKPMI: ${Object.keys(this.hkpmiSchema).length} tables`);
			console.log(`   - HPI: ${Object.keys(this.hpiSchema).length} tables`);
		} catch (error) {
			console.error("❌ Error loading schemas:", error);
			process.exit(1);
		}
	}

	private extractLength(typeString: string): number | undefined {
		const match = typeString.match(/varchar\((\d+)\)/);
		return match ? parseInt(match[1]) : undefined;
	}

	private loadSPFile(filePath: string): void {
		try {
			this.spContent = fs.readFileSync(filePath, "utf8");
			console.log(`✅ Loaded SP file: ${this.spFilename}`);
		} catch (error) {
			console.error(`❌ Error loading SP file ${filePath}:`, error);
			process.exit(1);
		}
	}

	private identifySpecificTableReferences(): TableReference[] {
		const references: TableReference[] = [];
		const lines = this.spContent.split("\n");

		for (const line of lines) {
			const trimmedLine = line.trim();

			// Skip commented lines
			if (trimmedLine.startsWith("--") || trimmedLine.startsWith("/*")) {
				continue;
			}

			// Look for FROM clauses with schema.table pattern
			const fromMatch = trimmedLine.match(
				/from\s+([a-zA-Z_]+)\.([a-zA-Z_]+)\s+([A-Z]+)/i,
			);
			if (fromMatch && ["hkpmi", "hpi"].includes(fromMatch[1].toLowerCase())) {
				references.push({
					schema: fromMatch[1].toLowerCase(),
					table: fromMatch[2],
					alias: fromMatch[3],
				});
				continue;
			}

			// Look for comma-separated table references in FROM clauses
			const commaMatch = trimmedLine.match(
				/,\s*([a-zA-Z_]+)\.([a-zA-Z_]+)\s+([A-Z]+)/i,
			);
			if (
				commaMatch &&
				["hkpmi", "hpi"].includes(commaMatch[1].toLowerCase())
			) {
				references.push({
					schema: commaMatch[1].toLowerCase(),
					table: commaMatch[2],
					alias: commaMatch[3],
				});
				continue;
			}

			// Look for UPDATE ... FROM pattern
			const updateFromMatch = trimmedLine.match(
				/from\s+([a-zA-Z_]+)\.+([a-zA-Z_]+)\s+([a-zA-Z]+)/i,
			);
			if (
				updateFromMatch &&
				["hkpmi", "hpi"].includes(updateFromMatch[1].toLowerCase())
			) {
				references.push({
					schema: updateFromMatch[1].toLowerCase(),
					table: updateFromMatch[2],
					alias: updateFromMatch[3],
				});
			}
		}

		// Remove duplicates based on schema.table combination
		const uniqueRefs = references.filter(
			(ref, index, self) =>
				index ===
				self.findIndex((r) => r.schema === ref.schema && r.table === ref.table),
		);

		console.log(`🔍 Found ${uniqueRefs.length} specific table references:`);
		uniqueRefs.forEach((ref) => {
			console.log(`   - ${ref.schema}.${ref.table} (alias: ${ref.alias})`);
		});

		return uniqueRefs;
	}

	private extractTempTables(): TempTable[] {
		const tempTables: TempTable[] = [];

		// More flexible regex to match CREATE TEMPORARY TABLE with multi-line definitions
		const content = this.spContent.replace(/--.*$/gm, ""); // Remove line comments first
		const createTableRegex =
			/create\s+temporary\s+table\s+([a-zA-Z_]+)\s*\(\s*([\s\S]*?)\s*\);/gi;

		let match;
		while ((match = createTableRegex.exec(content)) !== null) {
			const tableName = match[1];
			const columnDef = match[2];

			const columns = this.parseColumnDefinitions(columnDef);

			if (columns.length > 0) {
				tempTables.push({
					name: tableName,
					columns: columns,
				});

				console.log(`   📋 Table: ${tableName}`);
				columns.forEach((col) => {
					console.log(
						`      - ${col.name}: ${col.type}${
							col.length ? `(${col.length})` : ""
						}`,
					);
				});
			}
		}

		console.log(`📋 Found ${tempTables.length} temporary tables with columns:`);

		return tempTables;
	}

	private parseColumnDefinitions(columnDef: string): TempTableColumn[] {
		const columns: TempTableColumn[] = [];

		// Remove comments and normalize whitespace
		let cleanDef = columnDef
			.replace(/--.*$/gm, "") // Remove line comments
			.replace(/\/\*.*?\*\//gs, "") // Remove block comments
			.replace(/\s+/g, " ") // Normalize whitespace
			.trim();

		// Split by lines that start with a comma (indicating new column)
		const lines = cleanDef.split(/\n|,(?=\s*[a-zA-Z_])/);

		for (let line of lines) {
			line = line.trim().replace(/^,/, "").trim(); // Remove leading comma

			if (!line) continue;

			// Parse column definition: column_name data_type(length) [null]
			const columnMatch = line.match(
				/^([a-zA-Z_]+)\s+(char|varchar|timestamp|int|integer|bigint|numeric|decimal|text|boolean)\s*(?:\((\d+)\))?\s*(?:null|not\s+null)?\s*/i,
			);

			if (columnMatch) {
				const columnName = columnMatch[1];
				const dataType = columnMatch[2].toLowerCase();
				const length = columnMatch[3] ? parseInt(columnMatch[3]) : undefined;

				columns.push({
					name: columnName,
					type: dataType,
					length: length,
				});
			}
		}

		return columns;
	}

	private findMatchingColumnsInSpecificTables(
		columnName: string,
		tableRefs: TableReference[],
	): Array<{ schema: string; table: string; column: ColumnInfo }> {
		const matches: Array<{
			schema: string;
			table: string;
			column: ColumnInfo;
		}> = [];

		for (const ref of tableRefs) {
			const schemaData =
				ref.schema === "hkpmi"
					? this.hkpmiSchema
					: ref.schema === "hpi"
						? this.hpiSchema
						: null;

			if (!schemaData) continue;

			const tableData = schemaData[ref.table];
			if (!tableData) continue;

			const matchingColumn = tableData.columns.find(
				(col) => col.column_name.toLowerCase() === columnName.toLowerCase(),
			);

			if (matchingColumn) {
				matches.push({
					schema: ref.schema,
					table: ref.table,
					column: matchingColumn,
				});
			}
		}

		return matches;
	}

	private findColumnMismatches(
		tempTables: TempTable[],
		tableRefs: TableReference[],
	): MismatchRecord[] {
		const mismatches: MismatchRecord[] = [];

		for (const tempTable of tempTables) {
			for (const column of tempTable.columns) {
				// Only check CHAR and VARCHAR types
				if (!["char", "varchar"].includes(column.type)) {
					continue;
				}

				// Find matching columns in specifically referenced schema tables
				const matches = this.findMatchingColumnsInSpecificTables(
					column.name,
					tableRefs,
				);

				for (const match of matches) {
					const schemaColumn = match.column;

					// Check for type mismatches
					if (this.isTypeMismatch(column, schemaColumn)) {
						const mismatchType = this.describeMismatch(column, schemaColumn);
						const possibleDataType = this.suggestCorrection(schemaColumn);

						mismatches.push({
							filename: this.spFilename,
							table_name: tempTable.name,
							column_name: column.name,
							data_type: this.formatColumnType(column),
							possible_data_type: possibleDataType,
							source_files_tables: `${match.schema}.${match.table}`,
							mismatch_type: mismatchType,
						});
					}
				}
			}
		}

		return mismatches;
	}

	private isTypeMismatch(
		spColumn: TempTableColumn,
		schemaColumn: ColumnInfo,
	): boolean {
		// CHAR vs VARCHAR mismatch
		if (
			spColumn.type === "char" &&
			schemaColumn.data_type === "character varying"
		) {
			return true;
		}

		// VARCHAR length mismatch
		if (
			spColumn.type === "varchar" &&
			schemaColumn.data_type === "character varying"
		) {
			if (spColumn.length && schemaColumn.character_maximum_length) {
				return spColumn.length !== schemaColumn.character_maximum_length;
			}
		}

		return false;
	}

	private describeMismatch(
		spColumn: TempTableColumn,
		schemaColumn: ColumnInfo,
	): string {
		const spType = this.formatColumnType(spColumn);
		const schemaType = this.formatSchemaColumnType(schemaColumn);

		return `${spType} vs ${schemaType} type mismatch`;
	}

	private formatColumnType(column: TempTableColumn): string {
		if (column.length) {
			return `${column.type}(${column.length})`;
		}
		return column.type;
	}

	private formatSchemaColumnType(column: ColumnInfo): string {
		if (
			column.data_type === "character varying" &&
			column.character_maximum_length
		) {
			return `VARCHAR(${column.character_maximum_length})`;
		}
		return column.data_type.toUpperCase();
	}

	private suggestCorrection(schemaColumn: ColumnInfo): string {
		if (
			schemaColumn.data_type === "character varying" &&
			schemaColumn.character_maximum_length
		) {
			return `varchar(${schemaColumn.character_maximum_length})`;
		}
		return schemaColumn.data_type;
	}

	private generateCSV(mismatches: MismatchRecord[]): string {
		const headers = [
			"filename",
			"table_name",
			"column_name",
			"data_type",
			"possible_data_type",
			"source_files_tables",
			"mismatch_type",
		];

		const csvRows = [
			headers.join(","),
			...mismatches.map((record) =>
				[
					`"${record.filename}"`,
					`"${record.table_name}"`,
					`"${record.column_name}"`,
					`"${record.data_type}"`,
					`"${record.possible_data_type}"`,
					`"${record.source_files_tables}"`,
					`"${record.mismatch_type}"`,
				].join(","),
			),
		];

		return csvRows.join("\n");
	}

	public analyze(): void {
		console.log(`\n🔍 Analyzing SP: ${this.spFilename}`);
		console.log("=".repeat(60));

		// Step 1: Identify specific table references
		const tableRefs = this.identifySpecificTableReferences();

		// Step 2: Extract temporary tables
		const tempTables = this.extractTempTables();

		// Step 3: Find column mismatches
		const mismatches = this.findColumnMismatches(tempTables, tableRefs);

		// Step 4: Generate results
		console.log(`\n📊 Analysis Results:`);
		console.log(`   - Total mismatches found: ${mismatches.length}`);

		if (mismatches.length > 0) {
			// Generate CSV
			const csv = this.generateCSV(mismatches);
			const outputFile = this.spFilename.replace(
				".sql",
				"_column_mismatches.csv",
			);

			fs.writeFileSync(outputFile, csv);
			console.log(`✅ CSV report saved to: ${outputFile}`);

			// Show summary
			const groupedByTable = mismatches.reduce(
				(acc, mismatch) => {
					if (!acc[mismatch.source_files_tables]) {
						acc[mismatch.source_files_tables] = 0;
					}
					acc[mismatch.source_files_tables]++;
					return acc;
				},
				{} as Record<string, number>,
			);

			console.log(`\n📋 Mismatches by source table:`);
			Object.entries(groupedByTable).forEach(([table, count]) => {
				console.log(`   - ${table}: ${count} mismatches`);
			});
		} else {
			console.log(`✅ No column type mismatches found!`);
		}
	}
}

// Main execution
function main() {
	const args = process.argv.slice(2);

	if (args.length === 0) {
		console.error(
			"❌ Usage: npx tsx analyze_sp_mismatches_generic.ts <sp_file_path>",
		);
		console.error(
			"Example: npx tsx analyze_sp_mismatches_generic.ts contexts/schemas/sp/001_proc_cle_eflu_get_mgt_rpt.sql",
		);
		process.exit(1);
	}

	const spFilePath = args[0];

	// Check if file exists
	if (!fs.existsSync(spFilePath)) {
		console.error(`❌ File not found: ${spFilePath}`);
		process.exit(1);
	}

	try {
		const analyzer = new SPMismatchAnalyzer(spFilePath);
		analyzer.analyze();
	} catch (error) {
		console.error("❌ Analysis failed:", error);
		process.exit(1);
	}
}

// Auto-execute if this is the main module
main();
