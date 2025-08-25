import fs from "fs";
import path from "path";
import matter from "gray-matter";
import yaml from "js-yaml";
import { RulesCardWithDrawer } from "@/components/rules/RulesCard";
import { DockDemo } from "@/components/magicui/example/dock-demo";

type Tag = {
	slug: string;
	name: string;
};

type RuleDocument = {
	title: string;
	content: string;
	tags: string[];
	fileName: string;
	description: string;
};

async function getTagName(slug: string): Promise<string> {
	try {
		const tagsYamlPath = path.join(process.cwd(), "rules", "tags.yaml");
		const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
		const tagsList = yaml.load(tagsYamlContent) as Tag[];

		const foundTag = tagsList.find((tag) => tag.slug === slug);
		return foundTag?.name || slug;
	} catch (err) {
		console.error("Error loading tag name:", err);
		return slug;
	}
}

async function getRulesByTag(tag: string): Promise<RuleDocument[]> {
	const rulesDirectory = path.join(process.cwd(), "rules");
	const fileNames = fs
		.readdirSync(rulesDirectory)
		.filter((file) => file.endsWith(".md"));

	const allRules: RuleDocument[] = [];

	for (const fileName of fileNames) {
		const filePath = path.join(rulesDirectory, fileName);
		const fileContent = fs.readFileSync(filePath, "utf8");
		const { data, content } = matter(fileContent);

		if (data.tags && Array.isArray(data.tags) && data.tags.includes(tag)) {
			allRules.push({
				title: data.title || fileName.split(".")[0],
				content: content,
				tags: data.tags,
				description: data.description,
				fileName: fileName,
			});
		}
	}

	return allRules;
}

export default async function RulesPage({
	params,
}: {
	params: Promise<{ slug: [string, string?] }>;
}) {
	const { slug } = await params;
	const rules = await getRulesByTag(slug[0]);

	const tagName = await getTagName(slug[0]);

	return (
		<div className="p-8 pb-32">
			<h1 className="text-2xl font-bold mb-6">{tagName} Rules</h1>
			{rules.length > 0 ? (
				<div className="grid grid-cols-1 xl:grid-cols-2 2xl:grid-cols-3 gap-3">
					{rules.map((rule) => (
						<RulesCardWithDrawer
							key={rule.fileName}
							title={rule.title}
							description={rule.description}
							content={rule.content}
							tags={rule.tags}
							open={slug[1] === rule.fileName.split(".")[0]}
							href={`/prompts/${slug[0]}/${rule.fileName.split(".")[0]}`}
						/>
					))}
				</div>
			) : (
				<p className="text-muted-foreground">No rules found for tag: {slug}</p>
			)}
		</div>
	);
}
