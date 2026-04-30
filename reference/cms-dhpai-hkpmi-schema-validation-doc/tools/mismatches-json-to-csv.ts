#! npx tsx

import { readFileSync, writeFileSync } from "fs";
import { parseArgs } from "util";

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

interface CsvRow {
	filename: string;
	table_name: string;
	column_name: string;
	data_type: string;
	possible_data_type: string;
	source_files_tables: string;
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
Usage: npx tsx json-to-csv.ts <input-json-file> [options]

Description:
  Converts schema mismatch JSON file to CSV format. For each possible data type,
  creates a new row with information about the source files and tables.

Arguments:
  <input-json-file>    Path to the input JSON file (mismatch results)

Options:
  -o, --output <file>  Output CSV file path (if not specified, outputs to stdout)
  -h, --help          Show this help message

Examples:
  npx tsx json-to-csv.ts ./contexts/column-mismatches.json
  npx tsx json-to-csv.ts ./contexts/column-mismatches.json -o mismatches.csv
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

// Read and parse JSON file
function readJsonFile(filename: string): ResultRecord[] {
	try {
		const content = readFileSync(filename, "utf8");
		return JSON.parse(content);
	} catch (error) {
		console.error(`Error reading ${filename}:`, (error as Error).message);
		process.exit(1);
	}
}

// Convert JSON to CSV rows
function convertToCSV(data: ResultRecord[]): CsvRow[] {
	const csvRows: CsvRow[] = [];

	data.forEach((record) => {
		// For each possible data type, create a new row
		record.possible.forEach((possibleType) => {
			// Find all mismatches that have this possible type
			const matchingMismatches = record.mismatches.filter(
				(mismatch) => mismatch.type === possibleType,
			);

			// Create semicolon-separated list of file:table pairs
			const sourceFilesTablesArray = matchingMismatches.map(
				(mismatch) => `${mismatch.file}:${mismatch.table}`,
			);
			const sourceFilesTables = sourceFilesTablesArray.join("; ");

			csvRows.push({
				filename: record.filename,
				table_name: record.table_name,
				column_name: record.column_name,
				data_type: record.data_type,
				possible_data_type: possibleType,
				source_files_tables: sourceFilesTables,
			});
		});
	});

	return csvRows;
}

// Escape CSV field if it contains special characters
function escapeCsvField(field: string): string {
	if (field.includes(",") || field.includes('"') || field.includes("\n")) {
		return `"${field.replace(/"/g, '""')}"`;
	}
	return field;
}

// Convert CSV rows to CSV string
function formatCSV(rows: CsvRow[]): string {
	const headers = [
		"filename",
		"table_name",
		"column_name",
		"data_type",
		"possible_data_type",
		"source_files_tables",
	];

	const csvLines = [headers.join(",")];

	rows.forEach((row) => {
		const line = [
			escapeCsvField(row.filename),
			escapeCsvField(row.table_name),
			escapeCsvField(row.column_name),
			escapeCsvField(row.data_type),
			escapeCsvField(row.possible_data_type),
			escapeCsvField(row.source_files_tables),
		].join(",");
		csvLines.push(line);
	});

	return csvLines.join("\n");
}

// Main execution
function main() {
	const { inputFile, outputFile } = parseCliArgs();

	console.error("Reading JSON file...");
	const jsonData = readJsonFile(inputFile);

	console.error("Converting to CSV format...");
	const csvRows = convertToCSV(jsonData);

	console.error("Formatting CSV...");
	const csvContent = formatCSV(csvRows);

	// Write results to file or stdout
	if (outputFile) {
		writeFileSync(outputFile, csvContent);
		console.error(
			`Conversion complete. Generated ${csvRows.length} CSV rows from ${jsonData.length} JSON records.`,
		);
		console.error(`Results written to ${outputFile}`);
	} else {
		console.log(csvContent);
		console.error(
			`Conversion complete. Generated ${csvRows.length} CSV rows from ${jsonData.length} JSON records.`,
		);
	}
}

// Run the CLI
main();
