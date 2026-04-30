import {
	Table,
	getAllColumnTypesFromDirectory,
	getColumnTypeFromSqlFile,
} from "../src/main";
import fs from "fs/promises";
import path from "path";

async function processPath(
	inputPath: string,
): Promise<Array<{ file: string; tables: Table[] }>> {
	try {
		const stat = await fs.stat(inputPath);

		if (stat.isDirectory()) {
			return await getAllColumnTypesFromDirectory(inputPath);
		} else if (stat.isFile() && inputPath.toLowerCase().endsWith(".sql")) {
			const tables = await getColumnTypeFromSqlFile(inputPath);
			return [
				{
					file: path.basename(inputPath),
					tables: tables,
				},
			];
		} else {
			console.warn(`Skipping non-SQL file: ${inputPath}`);
			return [];
		}
	} catch (error) {
		console.error(`Error processing path ${inputPath}:`, error);
		return [];
	}
}

async function main() {
	const args = process.argv.slice(2);

	if (args.length === 0) {
		console.error(
			"Usage: npm run build && node dist/main.js [options] <folder_or_file> [folder_or_file2] ...",
		);
		console.error("Options:");
		console.error("  -o <filename>    Output JSON to file instead of stdout");
		console.error(
			"Example: npm run build && node dist/main.js -o output.json contexts/schemas/hpi contexts/schemas/hkpmi",
		);
		console.error(
			"Example: npm run build && node dist/main.js contexts/schemas/hpi > output.json",
		);
		process.exit(1);
	}

	let outputFile: string | null = null;
	let inputPaths: string[] = [];

	// Parse arguments
	for (let i = 0; i < args.length; i++) {
		if (args[i] === "-o" && i + 1 < args.length) {
			outputFile = args[i + 1];
			i++; // Skip the next argument as it's the filename
		} else {
			inputPaths.push(args[i]);
		}
	}

	if (inputPaths.length === 0) {
		console.error("Error: No input paths provided");
		process.exit(1);
	}

	console.log("Processing paths:", inputPaths);

	try {
		const allResults: Array<{ file: string; tables: Table[] }> = [];

		for (const inputPath of inputPaths) {
			const results = await processPath(inputPath);
			allResults.push(...results);
		}

		const output = JSON.stringify(allResults, null, 2);

		if (outputFile) {
			await fs.writeFile(outputFile, output, "utf-8");
			console.log(`Output written to: ${outputFile}`);
		} else {
			console.log(output);
		}

		console.info(`Processed ${allResults.length} files successfully.`);
	} catch (error) {
		console.error("Error during processing:", error);
		process.exit(1);
	}
}

main();
