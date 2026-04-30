#!/usr/bin/env node

/**
 * Generate a catalog page with vscode:// installation links from index.json
 *
 * Usage:
 *   node generate-catalog.js [index-json-path] [output-path] [publisher]
 */

const fs = require("fs");
const path = require("path");

// Default configuration
const DEFAULT_PUBLISHER = "your-publisher-name";
const EXTENSION_NAME = "awesome-copilot-ghe";
const DEFAULT_INDEX_PATH = "../../index.json";
const DEFAULT_OUTPUT_PATH = "CATALOG.md";

function generateLink(type, link, target = "ask", publisher) {
	const baseUrl = `vscode://${publisher}.${EXTENSION_NAME}/install`;
	const params = new URLSearchParams({ type, link, target });
	return `${baseUrl}?${params.toString()}`;
}

function generateCatalog(indexPath, publisher) {
	// Read index.json
	const indexData = JSON.parse(fs.readFileSync(indexPath, "utf-8"));

	let markdown = "# 📚 Awesome Copilot Catalog\n\n";
	markdown += "One-click installation links for Copilot items.\n\n";
	markdown +=
		"> **Note**: Links will open VS Code and prompt for installation.\n\n";
	markdown += "---\n\n";

	// Process each category
	const categories = [
		{ key: "instructions", label: "📋 Instructions", type: "instruction" },
		{ key: "prompts", label: "⚡ Prompts", type: "prompt" },
		{ key: "agents", label: "🎨 Agents", type: "agent" },
		{ key: "chatmodes", label: "💬 Chat Modes", type: "chatmode" },
		{ key: "collections", label: "📦 Collections", type: "collection" },
	];

	categories.forEach(({ key, label, type }) => {
		const items = indexData[key];
		if (!items || items.length === 0) {
			return;
		}

		markdown += `## ${label}\n\n`;

		items.forEach((item) => {
			const linkGlobal = generateLink(type, item.link, "global", publisher);
			const linkWorkspace = generateLink(
				type,
				item.link,
				"workspace",
				publisher,
			);
			const linkView = generateLink(type, item.link, "view", publisher);

			markdown += `### ${item.title}\n\n`;
			markdown += `${item.description}\n\n`;
			markdown += `**File**: \`${item.filename}\`\n\n`;
			markdown += `**Install**: `;
			markdown += `[Global](${linkGlobal}) | `;
			markdown += `[Workspace](${linkWorkspace}) | `;
			markdown += `[View](${linkView})\n\n`;
			markdown += "---\n\n";
		});
	});

	// Add footer
	markdown += "## How to Use\n\n";
	markdown += "1. Click an installation link above\n";
	markdown += "2. VS Code will open (if not already open)\n";
	markdown += "3. Authenticate if prompted\n";
	markdown += "4. The item will be installed\n\n";
	markdown += "### Installation Options\n\n";
	markdown +=
		"- **Global**: Installs to your user profile (available in all workspaces)\n";
	markdown +=
		"- **Workspace**: Installs to current workspace `.github/` folders\n";
	markdown += "- **View**: Opens in editor without installing\n\n";

	return markdown;
}

function generateHTML(indexPath, publisher) {
	const indexData = JSON.parse(fs.readFileSync(indexPath, "utf-8"));

	let html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Awesome Copilot Catalog</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #007acc;
            padding-bottom: 10px;
        }
        h2 {
            color: #555;
            margin-top: 30px;
        }
        .item {
            background: white;
            border: 1px solid #ddd;
            padding: 20px;
            margin: 15px 0;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .item h3 {
            margin-top: 0;
            color: #007acc;
        }
        .item p {
            color: #666;
            line-height: 1.6;
        }
        .item .filename {
            background: #f0f0f0;
            padding: 4px 8px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 0.9em;
        }
        .install-buttons {
            margin-top: 15px;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-right: 10px;
            margin-top: 5px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: 500;
            transition: all 0.2s;
        }
        .btn-global {
            background-color: #007acc;
            color: white;
        }
        .btn-global:hover {
            background-color: #005a9e;
        }
        .btn-workspace {
            background-color: #28a745;
            color: white;
        }
        .btn-workspace:hover {
            background-color: #218838;
        }
        .btn-view {
            background-color: #6c757d;
            color: white;
        }
        .btn-view:hover {
            background-color: #545b62;
        }
        .category {
            margin: 40px 0;
        }
        .info-box {
            background: #e7f3ff;
            border-left: 4px solid #007acc;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <h1>📚 Awesome Copilot Catalog</h1>
    
    <div class="info-box">
        <strong>💡 How to use:</strong> Click any install button to open VS Code and install the item.
        Choose <strong>Global</strong> for all workspaces, <strong>Workspace</strong> for current project, or <strong>View</strong> to preview.
    </div>
`;

	const categories = [
		{ key: "instructions", label: "📋 Instructions", type: "instruction" },
		{ key: "prompts", label: "⚡ Prompts", type: "prompt" },
		{ key: "agents", label: "🎨 Agents", type: "agent" },
		{ key: "chatmodes", label: "💬 Chat Modes", type: "chatmode" },
		{ key: "collections", label: "📦 Collections", type: "collection" },
	];

	categories.forEach(({ key, label, type }) => {
		const items = indexData[key];
		if (!items || items.length === 0) {
			return;
		}

		html += `\n    <div class="category">\n`;
		html += `        <h2>${label}</h2>\n`;

		items.forEach((item) => {
			const linkGlobal = generateLink(type, item.link, "global", publisher);
			const linkWorkspace = generateLink(
				type,
				item.link,
				"workspace",
				publisher,
			);
			const linkView = generateLink(type, item.link, "view", publisher);

			html += `\n        <div class="item">\n`;
			html += `            <h3>${item.title}</h3>\n`;
			html += `            <p>${item.description}</p>\n`;
			html += `            <p><span class="filename">${item.filename}</span></p>\n`;
			html += `            <div class="install-buttons">\n`;
			html += `                <a href="${linkGlobal}" class="btn btn-global">📥 Install Globally</a>\n`;
			html += `                <a href="${linkWorkspace}" class="btn btn-workspace">📁 Install to Workspace</a>\n`;
			html += `                <a href="${linkView}" class="btn btn-view">👁️ Preview</a>\n`;
			html += `            </div>\n`;
			html += `        </div>\n`;
		});

		html += `    </div>\n`;
	});

	html += `
</body>
</html>`;

	return html;
}

// Main execution
const args = process.argv.slice(2);
const indexPath = args[0] || path.join(__dirname, DEFAULT_INDEX_PATH);
const outputPath = args[1] || DEFAULT_OUTPUT_PATH;
const publisher = args[2] || DEFAULT_PUBLISHER;

if (!fs.existsSync(indexPath)) {
	console.error(`❌ Error: Index file not found: ${indexPath}`);
	console.log("\nUsage:");
	console.log(
		"  node generate-catalog.js [index-json-path] [output-path] [publisher]",
	);
	process.exit(1);
}

try {
	// Generate Markdown catalog
	const markdownCatalog = generateCatalog(indexPath, publisher);
	fs.writeFileSync(outputPath, markdownCatalog);
	console.log(`✅ Generated Markdown catalog: ${outputPath}`);

	// Generate HTML catalog
	const htmlPath = outputPath.replace(/\.md$/, ".html");
	const htmlCatalog = generateHTML(indexPath, publisher);
	fs.writeFileSync(htmlPath, htmlCatalog);
	console.log(`✅ Generated HTML catalog: ${htmlPath}`);

	console.log("\n📖 Catalog files created successfully!");
	console.log(`   - Markdown: ${outputPath}`);
	console.log(`   - HTML: ${htmlPath}`);
} catch (error) {
	console.error("❌ Error generating catalog:", error.message);
	process.exit(1);
}
