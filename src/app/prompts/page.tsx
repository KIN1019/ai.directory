import { redirect } from "next/navigation";
import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import matter from "gray-matter";

type Tag = {
	slug: string;
	name: string;
};

export default async function RulesHome() {
	// Read tags.yaml to get the first tag
	const tagsYamlPath = path.join(
		process.cwd(),
		"resources",
		"rules",
		"tags.yaml",
	);
	const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
	const tagsList = yaml.load(tagsYamlContent) as Tag[];

	// Count occurrences of tags in markdown files
	const rulesDirectory = path.join(process.cwd(), "resources", "rules");
	const fileNames = fs
		.readdirSync(rulesDirectory)
		.filter((file) => file.endsWith(".md"));
	const tagCounts = new Map<string, number>();
	for (const fileName of fileNames) {
		const filePath = path.join(rulesDirectory, fileName);
		const fileContent = fs.readFileSync(filePath, "utf8");
		const { data } = matter(fileContent);
		if (data.tags && Array.isArray(data.tags)) {
			data.tags.forEach((tag: string) => {
				tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
			});
		}
	}

	// Attach counts to tags and sort by descending count
	const tagsWithCount = tagsList.map((tag) => ({
		...tag,
		count: tagCounts.get(tag.slug) || 0,
	}));
	tagsWithCount.sort((a, b) => b.count - a.count);

	// Get the first tag (highest count), or default to 'react' if no tags exist
	const firstTag = tagsWithCount.length > 0 ? tagsWithCount[0].slug : "react";

	// Redirect to the first tag's page
	redirect(`/prompts/${firstTag}`);
}
