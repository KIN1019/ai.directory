import { NextRequest, NextResponse } from "next/server";
import fs from "node:fs";
import path from "node:path";

function isMarkdownFile(filePath: string) {
	const lowerCasePath = filePath.toLowerCase();
	return (
		lowerCasePath.endsWith(".md") ||
		lowerCasePath.endsWith(".markdown") ||
		lowerCasePath.endsWith(".mdx")
	);
}

export async function GET(request: NextRequest) {
	const { searchParams } = new URL(request.url);
	const folderPath = searchParams.get("folderPath");
	const relativePath = searchParams.get("relativePath");

	if (!folderPath || !relativePath) {
		return NextResponse.json(
			{ error: "Missing folderPath or relativePath parameter" },
			{ status: 400 },
		);
	}

	const allowedBase = path.resolve(process.cwd(), "reference");
	const resolvedFolderPath = path.resolve(process.cwd(), folderPath);

	if (!resolvedFolderPath.startsWith(allowedBase + path.sep)) {
		return NextResponse.json({ error: "Invalid folder path" }, { status: 403 });
	}

	if (
		!fs.existsSync(resolvedFolderPath) ||
		!fs.statSync(resolvedFolderPath).isDirectory()
	) {
		return NextResponse.json({ error: "Folder not found" }, { status: 404 });
	}

	const resolvedFilePath = path.resolve(resolvedFolderPath, relativePath);

	if (!resolvedFilePath.startsWith(resolvedFolderPath + path.sep)) {
		return NextResponse.json({ error: "Invalid file path" }, { status: 403 });
	}

	if (!isMarkdownFile(resolvedFilePath)) {
		return NextResponse.json(
			{ error: "Only markdown files can be previewed" },
			{ status: 400 },
		);
	}

	if (
		!fs.existsSync(resolvedFilePath) ||
		!fs.statSync(resolvedFilePath).isFile()
	) {
		return NextResponse.json({ error: "File not found" }, { status: 404 });
	}

	const rawContent = fs.readFileSync(resolvedFilePath, "utf8");

	return NextResponse.json({
		content: rawContent,
		fileName: path.basename(resolvedFilePath),
		relativePath,
	});
}
