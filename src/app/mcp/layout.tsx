import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import { Suspense } from "react";
import { McpMultiSelectSidebar } from "./McpMultiSelectSidebar";
import { getLeadingNumber } from "@/lib/utils";
type Tag = {
	slug: string;
	name: string;
	count: number;
};

type McpData = {
	name: string;
	description: string;
	logo: string;
	tools: Array<{
		name: string;
		description: string;
	}>;
	config: {
		type: "sse" | "stdio";
		url?: string;
		command?: string;
	};
	tags: string[];
};

async function getMcpTags() {
	try {
		const mcpDirectory = path.join(process.cwd(), "resources", "mcp");
		const fileNames = fs
			.readdirSync(mcpDirectory)
			.filter((file) => file.endsWith(".yaml") && file !== "tags.yaml");

		const tagsYamlPath = path.join(mcpDirectory, "tags.yaml");
		const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
		const tagsList = yaml.load(tagsYamlContent) as Array<{
			slug: string;
			name: string;
		}>;

		const tagsMap = new Map<string, { slug: string; name: string }>();
		tagsList.forEach((tag) => tagsMap.set(tag.slug, tag));

		const tagCounts = new Map<string, number>();
		const uniqueTags = new Set<string>();

		fileNames
			.sort((a, b) => {
				const numA = getLeadingNumber(a);
				const numB = getLeadingNumber(b);

				if (!isNaN(numA) && !isNaN(numB) && numA !== numB) {
					return numA - numB;
				}

				return a.localeCompare(b);
			})
			.forEach((fileName) => {
				const filePath = path.join(mcpDirectory, fileName);
				const fileContent = fs.readFileSync(filePath, "utf8");
				const mcpData = yaml.load(fileContent) as McpData;

				if (mcpData.tags && Array.isArray(mcpData.tags)) {
					mcpData.tags.forEach((tag: string) => {
						uniqueTags.add(tag);
						tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
					});
				}
			});

		const validTags: Tag[] = [];
		const missingTags: string[] = [];

		uniqueTags.forEach((tag) => {
			if (tagsMap.has(tag)) {
				const tagData = tagsMap.get(tag)!;
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
				`Tags found in MCP files but not defined in tags.yaml: ${missingTags.join(", ")}`,
			);
		}

		return { tags: validTags };
	} catch (err) {
		console.error("Error loading MCP tags:", err);
		return { error: err instanceof Error ? err.message : "Unknown error" };
	}
}

export default async function McpLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	const { tags, error } = await getMcpTags();

	return (
		<main className="flex min-h-screen">
			<Suspense
				fallback={
					<div className="w-[250px] border-r min-h-screen">
						<div className="p-4">
							<h2 className="text-sm font-semibold ml-1">Tags</h2>
							<div className="space-y-1 mt-4">
								<div className="h-8 bg-muted animate-pulse rounded"></div>
								<div className="h-8 bg-muted animate-pulse rounded"></div>
								<div className="h-8 bg-muted animate-pulse rounded"></div>
							</div>
						</div>
					</div>
				}
			>
				<McpMultiSelectSidebar tags={tags || []} error={error} />
			</Suspense>
			<div className="flex-1 overflow-auto">{children}</div>
		</main>
	);
}
