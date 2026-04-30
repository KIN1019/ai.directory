#!/usr/bin/env node

import { readFileSync, writeFileSync } from "fs";

interface ColumnType {
	name: string;
	type: string;
}

interface TableData {
	file: string;
	tables: Array<{
		name: string;
		properties: ColumnType[];
	}>;
}

type ConflictType = {
	columnName: string;
	conflict: Array<{
		type: string;
		foundIn: Array<{ file: string; table: string }>;
	}>;
};

function main() {
	const inputFile = "./contexts/column-types-hpi.json";
	const outputFile = "./contexts/conflict-types.json";

	try {
		const data: TableData[] = JSON.parse(readFileSync(inputFile, "utf8"));

		const columnTypeMap = new Map<
			string,
			Array<{
				file: string;
				table: string;
				type: string;
			}>
		>();

		data.forEach((tableData) => {
			tableData.tables.forEach((table) => {
				table.properties.forEach((prop) => {
					const key = prop.name;
					const entry = {
						file: tableData.file,
						table: table.name,
						type: prop.type,
					};

					if (columnTypeMap.has(key)) {
						columnTypeMap.get(key)!.push(entry);
					} else {
						columnTypeMap.set(key, [entry]);
					}
				});
			});
		});

		const conflicts: ConflictType[] = [];

		columnTypeMap.forEach((entries, columnName) => {
			const uniqueTypes = new Set(entries.map((e) => e.type));

			if (uniqueTypes.size > 1) {
				const typeGroups = new Map<
					string,
					Array<{ file: string; table: string }>
				>();

				entries.forEach((entry) => {
					if (!typeGroups.has(entry.type)) {
						typeGroups.set(entry.type, []);
					}
					typeGroups.get(entry.type)!.push({
						file: entry.file,
						table: entry.table,
					});
				});

				const conflict: ConflictType = {
					columnName,
					conflict: [],
				};

				typeGroups.forEach((locations, type) => {
					conflict.conflict.push({
						type,
						foundIn: locations,
					});
				});

				conflicts.push(conflict);
			}
		});

		writeFileSync(outputFile, JSON.stringify(conflicts, null, 2));
		console.log(`Found ${conflicts.length} conflicting column type(s)`);

		conflicts.forEach((conflict) => {
			const types = [...new Set(conflict.conflict.map((c) => c.type))];
			console.log(`- ${conflict.columnName}: ${types.join(", ")}`);
		});
	} catch (error) {
		console.error("Error processing file:", error);
		process.exit(1);
	}
}

main();
