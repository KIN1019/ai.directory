#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const matter = require("gray-matter");
const yaml = require("js-yaml");

// Configuration
const CONFIG = {
	baseRepoUrl: "https://raw.githubusercontent.com/github/dhpai/main", // Update with your repo
	publisher: "dhpai", // VS Code publisher name
	extensionName: "dhpai", // Extension name

	// Redirect service configuration
	// HTTPS redirect links work everywhere (GitHub web, browsers, markdown previewers)
	// Direct vscode:// links may be blocked on GitHub web interface
	redirectService: {
		enabled: true, // Set to true to use HTTPS redirect links

		// GitHub Enterprise Pages URL
		baseUrl:
			"https://hagithub.home/pages/CMS/cms-dhpai-copilot-template/redirect",

		// Other examples:
		// Microsoft's service: 'https://aka.ms/dhpai/install'
		// GitHub.com: 'https://YOUR-USERNAME.github.io/YOUR-REPO/redirect'
		// Custom domain: 'https://install.your-domain.com'
	},

	directories: {
		instructions: {
			dir: "instructions",
			extension: ".instructions.md",
			outputFile: "docs/README.instructions.md",
			title: "📋 Custom Instructions",
			emoji: "📋",
			description:
				"Team and project-specific instructions to enhance GitHub Copilot's behavior for specific technologies and coding practices.",
		},
		prompts: {
			dir: "prompts",
			extension: ".prompt.md",
			outputFile: "docs/README.prompts.md",
			title: "🎯 Prompt Templates",
			emoji: "🎯",
			description:
				"Reusable prompt templates to accelerate common development tasks and workflows.",
		},
		collections: {
			dir: "collections",
			extension: ".collection.yml",
			outputFile: "docs/README.collections.md",
			title: "📦 Collections",
			emoji: "📦",
			description:
				"Curated collections of instructions, prompts, and agents organized by theme or project.",
		},
		agents: {
			dir: "agents",
			extension: ".agent.md",
			outputFile: "docs/README.agents.md",
			title: "🤖 Agents",
			emoji: "🤖",
			description:
				"Autonomous agents that can perform complex tasks and workflows.",
		},
	},
};

/**
 * Extract title and description from a markdown file
 */
function extractMetadataFromMarkdown(filePath) {
	try {
		const content = fs.readFileSync(filePath, "utf8");
		const parsed = matter(content);

		let title = parsed.data.title || parsed.data.name;
		let description = parsed.data.description || "";

		// If title is not in frontmatter, try to extract from first heading
		if (!title) {
			const headingMatch = parsed.content.match(/^#\s+(.+)$/m);
			if (headingMatch) {
				title = headingMatch[1].trim();
			}
		}

		// Use filename as fallback title
		if (!title) {
			title = path
				.basename(filePath)
				.replace(/\.(instructions|prompt|agent)\.md$/, "");
		}

		return { title, description };
	} catch (error) {
		console.error(`Error reading file ${filePath}:`, error.message);
		return { title: path.basename(filePath), description: "" };
	}
}

/**
 * Extract metadata from a YAML collection file
 */
function extractMetadataFromYAML(filePath) {
	try {
		const content = fs.readFileSync(filePath, "utf8");
		const data = yaml.load(content);

		return {
			title: data.name || path.basename(filePath, ".collection.yml"),
			description: data.description || "",
		};
	} catch (error) {
		console.error(`Error reading YAML file ${filePath}:`, error.message);
		return { title: path.basename(filePath), description: "" };
	}
}

/**
 * Generate installation link - either direct vscode:// or HTTPS redirect
 */
function generateInstallLink(
	filePath,
	vscodeVariant = "vscode",
	target = "ask",
) {
	const type = getTypeFromPath(filePath);
	const typeMap = {
		instructions: "instruction",
		prompts: "prompt",
		collections: "collection",
		agents: "agent",
	};

	const itemType = typeMap[type] || type;
	const normalizedPath = filePath.replace(/\\/g, "/");

	// Build the vscode:// protocol URL
	const params = new URLSearchParams({
		type: itemType,
		link: normalizedPath,
		target: target,
	});
	const vscodeUrl = `${vscodeVariant}://${CONFIG.publisher}.${CONFIG.extensionName}/install?${params.toString()}`;

	// If redirect service is enabled, wrap in HTTPS redirect
	if (CONFIG.redirectService && CONFIG.redirectService.enabled) {
		const encodedVscodeUrl = encodeURIComponent(vscodeUrl);
		// Don't include itemType in path - redirect service uses query param only
		return `${CONFIG.redirectService.baseUrl}/?url=${encodedVscodeUrl}`;
	}

	// Otherwise return direct vscode:// link
	return vscodeUrl;
}

/**
 * Get type from file path
 */
function getTypeFromPath(filePath) {
	for (const [type, config] of Object.entries(CONFIG.directories)) {
		if (filePath.startsWith(config.dir)) {
			return type;
		}
	}
	return null;
}

/**
 * Scan directory for files
 */
function scanDirectory(dirPath, extension) {
	const files = [];

	if (!fs.existsSync(dirPath)) {
		console.warn(`Directory not found: ${dirPath}`);
		return files;
	}

	const items = fs.readdirSync(dirPath);

	for (const item of items) {
		const itemPath = path.join(dirPath, item);
		const stat = fs.statSync(itemPath);

		if (stat.isFile() && item.endsWith(extension)) {
			// Skip template files
			if (item.toUpperCase().includes("TEMPLATE")) {
				continue;
			}
			files.push(itemPath);
		}
	}

	return files.sort();
}

/**
 * Generate markdown table row
 */
function generateTableRow(filePath, metadata, type) {
	const relativePath = filePath.replace(/\\/g, "/");

	// Generate links for both VS Code and VS Code Insiders
	const vscodeLink = generateInstallLink(relativePath, "vscode", "ask");
	const vscodeInsidersLink = generateInstallLink(
		relativePath,
		"vscode-insiders",
		"ask",
	);

	const title = metadata.title || path.basename(filePath);
	const description = metadata.description || "";

	// Generate install buttons using markdown syntax (works with HTTPS redirect links)
	const vscodeButton = `[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](${vscodeLink})`;
	const vscodeInsidersButton = `[![Install in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install-24bfa5?style=flat-square&logo=visualstudiocode&logoColor=white)](${vscodeInsidersLink})`;

	return `| [${title}](../${relativePath})<br />${vscodeButton}<br />${vscodeInsidersButton} | ${description} |`;
}

/**
 * Generate markdown content for a type
 */
function generateMarkdownForType(type, config) {
	console.log(`\nGenerating documentation for ${type}...`);

	const files = scanDirectory(config.dir, config.extension);

	if (files.length === 0) {
		console.warn(`No files found in ${config.dir}`);
		return null;
	}

	console.log(`Found ${files.length} files`);

	const rows = [];

	for (const file of files) {
		let metadata;

		if (config.extension === ".collection.yml") {
			metadata = extractMetadataFromYAML(file);
		} else {
			metadata = extractMetadataFromMarkdown(file);
		}

		const row = generateTableRow(file, metadata, type);
		rows.push(row);
	}

	const markdown = `# ${config.title}

${config.description}

### How to Use ${config.title}

**To Install:**
- Click the **Install in VS Code** or **Install in VS Code Insiders** button for the item you want
- The extension will prompt you to choose where to install (globally or to workspace)
- Or download the file manually and add it to your project

**To Use/Apply:**
${
	type === "instructions"
		? `- Instructions automatically apply to Copilot behavior once installed
- Global installations apply to all workspaces
- Workspace installations apply only to the current project
- You can also copy content to \`.github/copilot-instructions.md\` manually`
		: type === "prompts"
			? `- Invoke prompts in GitHub Copilot Chat using \`#\` followed by the prompt name
- Use prompts to accelerate common development tasks
- Prompts can be installed globally or per-workspace
- Customize prompts for your specific project needs`
			: type === "collections"
				? `- Collections bundle related instructions, prompts, and agents
- Install entire collections to quickly set up Copilot for a project
- Choose global or workspace installation
- Collections can be customized and extended for your needs`
				: `- Install agents to enable autonomous task execution
- Agents can perform complex workflows with minimal user intervention
- Choose installation scope (global or workspace)
- Configure agents for your specific development scenarios`
}

| Title | Description |
| ----- | ----------- |
${rows.join("\n")}

---

**Generated:** ${new Date().toISOString()}
`;

	return markdown;
}

/**
 * Main function
 */
function main() {
	console.log("🚀 Generating documentation with installation links...\n");

	// Create docs directory if it doesn't exist
	const docsDir = "docs";
	if (!fs.existsSync(docsDir)) {
		fs.mkdirSync(docsDir, { recursive: true });
		console.log(`Created directory: ${docsDir}`);
	}

	let generatedCount = 0;

	// Generate documentation for each type
	for (const [type, config] of Object.entries(CONFIG.directories)) {
		const markdown = generateMarkdownForType(type, config);

		if (markdown) {
			fs.writeFileSync(config.outputFile, markdown, "utf8");
			console.log(`✅ Generated: ${config.outputFile}`);
			generatedCount++;
		}
	}

	console.log(
		`\n✨ Successfully generated ${generatedCount} documentation files!`,
	);
	console.log("\n📝 Next steps:");
	console.log("   1. Review the generated files in the docs/ directory");
	console.log(
		"   2. Update CONFIG.baseRepoUrl in scripts/generate-docs.js with your repository URL",
	);
	console.log("   3. Commit the changes to your repository");
}

// Run the script
main();
