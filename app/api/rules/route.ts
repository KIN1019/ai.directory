import fs from "fs";
import path from "path";
import matter from "gray-matter";
import { NextResponse } from "next/server";

export async function GET(request: Request) {
	const { searchParams } = new URL(request.url);
	const query = searchParams.get("q")?.toLowerCase() || "";
	const rulesDir = path.join(process.cwd(), "rules");
	let fileNames: string[] = [];

	try {
		fileNames = fs.readdirSync(rulesDir).filter((file) => file.endsWith(".md"));
	} catch (err) {
		return NextResponse.json(
			{ error: "Cannot read rules directory" },
			{ status: 500 },
		);
	}

	const rules = fileNames.map((fileName) => {
		const filePath = path.join(rulesDir, fileName);
		const fileContent = fs.readFileSync(filePath, "utf8");
		const { data, content } = matter(fileContent);
		return {
			slug: fileName.replace(/\.md$/, ""),
			title: data.title || fileName.replace(/\.md$/, ""),
			description: data.description || "",
			tags: Array.isArray(data.tags) ? data.tags : [],
			content,
		};
	});

	const filtered = query
		? rules.filter(
				(rule) =>
					rule.title.toLowerCase().includes(query) ||
					rule.content.toLowerCase().includes(query),
			)
		: rules;

	return NextResponse.json(filtered);
}
