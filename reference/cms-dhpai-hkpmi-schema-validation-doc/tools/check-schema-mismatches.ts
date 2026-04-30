#! npx tsx

import { readFileSync, writeFileSync } from "fs";
import { parseArgs } from "util";

interface ColumnDefinition {
	name: string;
	type: string;
}

interface TableDefinition {
	name: string;
	properties: ColumnDefinition[];
}

interface FileDefinition {
	file: string;
	tables: TableDefinition[];
}

interface ColumnInstance {
	file: string;
	table: string;
	type: string;
	source: string;
}

interface MismatchRecord {
	file: string;
	table: string;
	type: string;
}

interface ResultRecord {
	filename: string;
	table_name: string;
	column_name: string;
	data_type: string;
	mismatches: MismatchRecord[];
	possible: string[];
}

// Parse command line arguments
function parseCliArgs() {
	try {
		const { values, positionals } = parseArgs({
			args: process.argv.slice(2),
			options: {
				output: {
					type: "string",
					short: "o",
				},
				help: {
					type: "boolean",
					short: "h",
				},
			},
			allowPositionals: true,
		});

		if (values.help) {
			console.log(`
Usage: npx tsx check-schema-mismatches.ts <input-json-file> [options]

Description:
  Checks for schema mismatches by comparing column types in an input schema 
  against HPI and HKPMI reference schemas. Identifies type mismatches and 
  provides detailed mismatch information.

Arguments:
  <input-json-file>    Path to the input JSON file to check against references

Options:
  -o, --output <file>  Output file path (if not specified, outputs to stdout)
  -h, --help          Show this help message

Examples:
  npx tsx check-schema-mismatches.ts ./contexts/column-types-cp7.json
  npx tsx check-schema-mismatches.ts ./contexts/column-types-cp7.json -o mismatches.json
      `);
			process.exit(0);
		}

		if (positionals.length === 0) {
			console.error("Error: Input JSON file is required");
			console.error("Use --help for usage information");
			process.exit(1);
		}

		return {
			inputFile: positionals[0],
			outputFile: values.output,
		};
	} catch (error) {
		console.error("Error parsing arguments:", (error as Error).message);
		process.exit(1);
	}
}

// File paths (reference files are always the same)
const referenceFiles = {
	hpi: "./contexts/column-types-hpi.json",
	hkpmi: "./contexts/column-types-hkpmi.json",
};

// Read and parse JSON files
function readJsonFile(filename: string): FileDefinition[] {
	try {
		const content = readFileSync(filename, "utf8");
		return JSON.parse(content);
	} catch (error) {
		console.error(`Error reading ${filename}:`, (error as Error).message);
		process.exit(1);
	}
}

// Create a map of column names to their type information
function buildColumnMap(
	data: FileDefinition[],
	sourceFile: string,
): Map<string, ColumnInstance[]> {
	const map = new Map<string, ColumnInstance[]>();

	data.forEach((item) => {
		const fileName = item.file;
		if (item.tables) {
			item.tables.forEach((table) => {
				const tableName = table.name;
				if (table.properties) {
					table.properties.forEach((column) => {
						const columnName = column.name;
						const columnType = column.type;

						if (!map.has(columnName)) {
							map.set(columnName, []);
						}

						map.get(columnName)!.push({
							file: fileName,
							table: tableName,
							type: columnType,
							source: sourceFile,
						});
					});
				}
			});
		}
	});

	return map;
}

// Main comparison function
function compareColumnTypes(inputFile: string): ResultRecord[] {
	console.log("Reading JSON files...");

	const inputData = readJsonFile(inputFile);
	const hpiData = readJsonFile(referenceFiles.hpi);
	const hkpmiData = readJsonFile(referenceFiles.hkpmi);

	console.log("Building column maps...");

	const inputMap = buildColumnMap(inputData, inputFile);
	const hpiMap = buildColumnMap(hpiData, "column-types-hpi.json");
	const hkpmiMap = buildColumnMap(hkpmiData, "column-types-hkpmi.json");

	const results: ResultRecord[] = [];

	console.log("Comparing column types...");

	// Process columns from input file only (left join approach)
	for (const [columnName, inputEntries] of inputMap) {
		const hpiEntries = hpiMap.get(columnName) || [];
		const hkpmiEntries = hkpmiMap.get(columnName) || [];

		// Skip if column doesn't exist in either reference file
		if (hpiEntries.length === 0 && hkpmiEntries.length === 0) {
			continue;
		}

		// Process each input entry
		inputEntries.forEach((inputEntry) => {
			const mismatches: MismatchRecord[] = [];

			// Check HPI mismatches
			hpiEntries.forEach((hpiEntry) => {
				if (hpiEntry.type !== inputEntry.type) {
					mismatches.push({
						file: hpiEntry.file,
						table: hpiEntry.table,
						type: hpiEntry.type,
					});
				}
			});

			// Check HKPMI mismatches
			hkpmiEntries.forEach((hkpmiEntry) => {
				if (hkpmiEntry.type !== inputEntry.type) {
					mismatches.push({
						file: hkpmiEntry.file,
						table: hkpmiEntry.table,
						type: hkpmiEntry.type,
					});
				}
			});

			// Process mismatches if they exist
			if (mismatches.length > 0) {
				// Collect all possible types
				const possibleTypes = new Set<string>();
				mismatches.forEach((m) => possibleTypes.add(m.type));

				results.push({
					filename: inputEntry.file,
					table_name: inputEntry.table,
					column_name: columnName,
					data_type: inputEntry.type,
					possible: Array.from(possibleTypes).sort(),
					mismatches: mismatches,
				});
			}
		});
	}

	return results;
}

// Main execution
function main() {
	const { inputFile, outputFile } = parseCliArgs();

	// Execute comparison
	const mismatchResults = compareColumnTypes(inputFile);

	// Prepare output
	const output = JSON.stringify(mismatchResults, null, 2);

	// Write results to file or stdout
	if (outputFile) {
		writeFileSync(outputFile, output);
		console.log(
			`Comparison complete. Found ${mismatchResults.length} columns with mismatches.`,
		);
		console.log(`Results written to ${outputFile}`);
	} else {
		console.log(output);
	}

	// Optional: Display summary to stderr when outputting to stdout
	if (!outputFile) {
		console.error(
			`Comparison complete. Found ${mismatchResults.length} columns with mismatches.`,
		);
	}

	// Optional: Display summary
	if (mismatchResults.length > 0 && outputFile) {
		console.log("\nFirst few mismatched columns:");
		mismatchResults.slice(0, 5).forEach((item) => {
			console.log(`${item.column_name} (${item.data_type}):`);
			item.mismatches.forEach((mismatch) => {
				console.log(`  ${mismatch.file} -> ${mismatch.type}`);
			});
		});
	} else if (mismatchResults.length === 0 && outputFile) {
		console.log("\nNo data type mismatches found between the files.");
	}
}

// Run the CLI
main();
