import { PostgreSQLDDLLexer } from "./syntax/antlr/PostgreSQLDDLLexer";
import { PostgreSQLDDLParser } from "./syntax/antlr/PostgreSQLDDLParser";
import { CreateTableListener } from "./syntax/create-table-listener";
import { CharStream, CommonTokenStream, ParseTreeWalker } from "antlr4ng";
import fs from "fs/promises";

export type Table = {
	name: string;
	properties: Property[];
};

type Property = {
	name: string;
	type: string;
};

async function getColumnTypeFromSqlString(sql: string): Promise<Table[]> {
	const inputStream = CharStream.fromString(sql);
	const lexer = new PostgreSQLDDLLexer(inputStream);
	const tokenStream = new CommonTokenStream(lexer);
	const parser = new PostgreSQLDDLParser(tokenStream);

	const tree = parser.file();
	const listener = new CreateTableListener();
	ParseTreeWalker.DEFAULT.walk(listener, tree);
	const tablesRaw = listener.tables;

	return Object.keys(tablesRaw).map((tableName) => ({
		name: tableName,
		properties: Object.entries(
			tablesRaw[tableName] as Record<string, string>,
		).map(([name, type]) => ({
			name,
			type: type as string,
		})),
	}));
}

export async function getColumnTypeFromSqlFile(
	filePath: string,
): Promise<Table[]> {
	const sql = await fs.readFile(filePath, "utf-8");
	return getColumnTypeFromSqlString(sql);
}

async function getAllFileFromDirectory(dirPath: string): Promise<string[]> {
	const sqlFiles: string[] = [];

	async function walkDirectory(currentPath: string): Promise<void> {
		const dirEntries = await fs.readdir(currentPath, { withFileTypes: true });

		for (const entry of dirEntries) {
			const fullPath = `${currentPath}/${entry.name}`;

			if (entry.isDirectory()) {
				await walkDirectory(fullPath);
			} else if (entry.isFile() && entry.name.toLowerCase().endsWith(".sql")) {
				sqlFiles.push(fullPath);
			}
		}
	}

	await walkDirectory(dirPath);
	return sqlFiles;
}

export async function getAllColumnTypesFromDirectory(
	dirPath: string,
): Promise<Array<{ file: string; tables: Table[] }>> {
	const sqlFiles = await getAllFileFromDirectory(dirPath);

	const results = await Promise.all(
		sqlFiles.map(async (filePath) => ({
			file: filePath.split("/").pop() || filePath,
			tables: await getColumnTypeFromSqlFile(filePath),
		})),
	);

	return results;
}
