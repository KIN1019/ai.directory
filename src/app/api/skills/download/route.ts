import { NextRequest, NextResponse } from "next/server";
import fs from "node:fs";
import path from "node:path";
import JSZip from "jszip";

function addToZip(dir: string, zipFolder: JSZip) {
	const entries = fs.readdirSync(dir, { withFileTypes: true });
	for (const entry of entries) {
		const fullPath = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			addToZip(fullPath, zipFolder.folder(entry.name) ?? zipFolder);
		} else {
			zipFolder.file(entry.name, fs.readFileSync(fullPath));
		}
	}
}

export async function GET(request: NextRequest) {
	const { searchParams } = new URL(request.url);
	const folderPath = searchParams.get("path");
	const overrideName = searchParams.get("name");

	if (!folderPath) {
		return NextResponse.json(
			{ error: "Missing path parameter" },
			{ status: 400 },
		);
	}

	// Security: prevent path traversal — path must be inside reference
	const resolvedPath = path.resolve(process.cwd(), folderPath);
	const allowedBase = path.resolve(process.cwd(), "reference");

	if (!resolvedPath.startsWith(allowedBase + path.sep)) {
		return NextResponse.json({ error: "Invalid path" }, { status: 403 });
	}

	if (
		!fs.existsSync(resolvedPath) ||
		!fs.statSync(resolvedPath).isDirectory()
	) {
		return NextResponse.json({ error: "Folder not found" }, { status: 404 });
	}

	const zip = new JSZip();
	addToZip(resolvedPath, zip);

	// Use override name if provided (for Download All → repo name), else skill folder name
	const zipName = overrideName
		? overrideName.replaceAll(/[^a-zA-Z0-9._-]/g, "-")
		: path.basename(resolvedPath);
	const zipBuffer = await zip.generateAsync({ type: "nodebuffer" });

	return new NextResponse(new Uint8Array(zipBuffer), {
		headers: {
			"Content-Type": "application/zip",
			"Content-Disposition": `attachment; filename="${zipName}.zip"`,
		},
	});
}
