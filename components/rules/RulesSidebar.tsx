import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import matter from "gray-matter";
import { GenericSidebar } from "@/components/sidebar/sidebar";

type Tag = {
	slug: string;
	name: string;
	count?: number;
};

async function getRulesTags() {
	try {
		const rulesDirectory = path.join(process.cwd(), "rules");
		const fileNames = fs
			.readdirSync(rulesDirectory)
			.filter((file) => file.endsWith(".md"));

		const tagsYamlPath = path.join(rulesDirectory, "tags.yaml");
		const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
		const tagsList = yaml.load(tagsYamlContent) as Tag[];

		const tagsMap = new Map<string, Tag>();
		tagsList.forEach((tag) => tagsMap.set(tag.slug, tag));

		const tagCounts = new Map<string, number>();

		const uniqueTags = new Set<string>();

		fileNames.forEach((fileName) => {
			const filePath = path.join(rulesDirectory, fileName);
			const fileContent = fs.readFileSync(filePath, "utf8");
			const { data } = matter(fileContent);

			if (data.tags && Array.isArray(data.tags)) {
				data.tags.forEach((tag: string) => {
					uniqueTags.add(tag);
					// Increment tag count
					tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
				});
			}
		});

		// Check if all tags exist in tags.yaml
		const validTags: Tag[] = [];
		const missingTags: string[] = [];

		uniqueTags.forEach((tag) => {
			if (tagsMap.has(tag)) {
				const tagData = tagsMap.get(tag)!;
				// Add count to tag data
				validTags.push({
					...tagData,
					count: tagCounts.get(tag) || 0,
				});
			} else {
				missingTags.push(tag);
			}
		});

		if (missingTags.length > 0) {
			throw new Error(
				`Tags found in markdown but not defined in tags.yaml: ${missingTags.join(", ")}`,
			);
		}

		return { tags: validTags };
	} catch (err) {
		console.error("Error loading tags:", err);
		return { error: err instanceof Error ? err.message : "Unknown error" };
	}
}

async function RulesSidebar() {
	const { tags, error } = await getRulesTags();

	if (error) {
		return (
			<GenericSidebar
				items={[]}
				baseUrl="/prompts"
				errorMessage={error}
				emptyMessage="No tags found"
			/>
		);
	}

	const sortedTags = tags
		? [...tags].sort((a, b) => (b.count || 0) - (a.count || 0))
		: [];

	const sidebarItems = sortedTags.map(tag => ({
		slug: tag.slug,
		name: tag.name,
		count: tag.count || 0
	}));

	return (
		<GenericSidebar
			items={sidebarItems}
			baseUrl="/prompts"
			emptyMessage="No tags found"
		/>
	);
}

export { RulesSidebar };
