import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import { McpCardWithDialog } from "@/components/mcp/McpCard";

type Tag = {
	slug: string;
	name: string;
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
		args?: string[];
		env?: Record<string, string>;
	};
	tags: string[];
	href?: string;
};

type McpDocument = {
	name: string;
	description: string;
	logo: string;
	tools: Array<{
		name: string;
		description: string;
	}>;
	setupCode: { type: "sse", url: string } | { type: "stdio", command: string, args: string[], env: { [key: string]: string } };
	href: string;
	fileName: string;
};

async function getTagNames(slugs: string[]): Promise<string[]> {
	try {
		const tagsYamlPath = path.join(process.cwd(), "mcp", "tags.yaml");
		const tagsYamlContent = fs.readFileSync(tagsYamlPath, "utf8");
		const tagsList = yaml.load(tagsYamlContent) as Tag[];

		const tagMap = new Map(tagsList.map(tag => [tag.slug, tag.name]));
		return slugs.map(slug => tagMap.get(slug) || slug);
	} catch (err) {
		console.error("Error loading tag names:", err);
		return slugs;
	}
}

async function getMcpsByTags(selectedTags: string[]): Promise<McpDocument[]> {
	const mcpDirectory = path.join(process.cwd(), "mcp");
	const fileNames = fs
		.readdirSync(mcpDirectory)
		.filter((file) => file.endsWith(".yaml") && file !== "tags.yaml");

	const allMcps: McpDocument[] = [];

	for (const fileName of fileNames) {
		const filePath = path.join(mcpDirectory, fileName);
		const fileContent = fs.readFileSync(filePath, "utf8");
		const mcpData = yaml.load(fileContent) as McpData;

		// If no tags selected, include all MCPs
		// If tags selected, include MCPs that have at least one matching tag
		const shouldInclude = selectedTags.length === 0 || 
			(mcpData.tags && Array.isArray(mcpData.tags) && 
			 selectedTags.some(selectedTag => mcpData.tags.includes(selectedTag)));

		if (shouldInclude) {
			const setupCode = mcpData.config.type === "sse" 
				? { type: "sse" as const, url: mcpData.config.url! }
				: { 
					type: "stdio" as const, 
					command: mcpData.config.command!, 
					args: mcpData.config.args || [],
					env: mcpData.config.env || {}
				};

			allMcps.push({
				name: mcpData.name,
				description: mcpData.description,
				logo: mcpData.logo,
				tools: mcpData.tools,
				setupCode,
				href: mcpData.href || "#",
				fileName: fileName,
			});
		}
	}

	return allMcps;
}

export default async function McpPage({
	searchParams,
}: {
	searchParams: Promise<{ tags?: string; dialog?: string }>;
}) {
	const params = await searchParams;
	const selectedTags = params.tags ? params.tags.split(',').filter(Boolean) : [];
	const openDialog = params.dialog || null;
	
	const mcps = await getMcpsByTags(selectedTags);
	const tagNames = selectedTags.length > 0 ? await getTagNames(selectedTags) : [];

	const getPageTitle = () => {
		if (selectedTags.length === 0) {
			return "All MCPs";
		} else if (selectedTags.length === 1) {
			return `${tagNames[0]} MCPs`;
		} else {
			return `MCPs for ${tagNames.join(", ")}`;
		}
	};

	return (
		<div className="p-8">
			<div className="mb-6">
				<h1 className="text-2xl font-bold">{getPageTitle()}</h1>
				{selectedTags.length > 0 && (
					<p className="text-muted-foreground mt-2">
						Showing MCPs that match any of the selected tags
					</p>
				)}
			</div>

			{mcps.length > 0 ? (
				<div className="grid grid-cols-1 xl:grid-cols-2 2xl:grid-cols-3 gap-6">
					{mcps.map((mcp) => {
						const mcpSlug = mcp.fileName.replace('.yaml', '');
						return (
							<McpCardWithDialog
								key={mcp.fileName}
								name={mcp.name}
								description={mcp.description}
								logo={mcp.logo}
								tools={mcp.tools}
								setupCode={mcp.setupCode}
								href={mcp.href}
								fileName={mcp.fileName}
								open={openDialog === mcpSlug}
							/>
						);
					})}
				</div>
			) : (
				<p className="text-muted-foreground">
					{selectedTags.length > 0 
						? `No MCPs found for the selected tags: ${tagNames.join(", ")}`
						: "No MCPs found"
					}
				</p>
			)}
		</div>
	);
}