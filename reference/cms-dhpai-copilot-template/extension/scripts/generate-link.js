#!/usr/bin/env node

/**
 * Generate vscode:// installation links for Awesome Copilot items
 *
 * Usage:
 *   node generate-link.js <type> <path> [target] [publisher]
 *
 * Examples:
 *   node generate-link.js prompt prompts/test-gen.prompt.md
 *   node generate-link.js instruction instructions/java.instructions.md global
 *   node generate-link.js collection collections/react-bundle.collection.yml ask my-publisher
 */

// Default configuration - update these values
const DEFAULT_PUBLISHER = "your-publisher-name";
const EXTENSION_NAME = "awesome-copilot-ghe";

function generateLink(
	type,
	path,
	target = "ask",
	publisher = DEFAULT_PUBLISHER,
) {
	const baseUrl = `vscode://${publisher}.${EXTENSION_NAME}/install`;
	const params = new URLSearchParams({
		type,
		link: path,
		target,
	});
	return `${baseUrl}?${params.toString()}`;
}

function printUsage() {
	console.log("Generate vscode:// installation links");
	console.log("");
	console.log("Usage:");
	console.log("  node generate-link.js <type> <path> [target] [publisher]");
	console.log("");
	console.log("Parameters:");
	console.log("  type       instruction|prompt|agent|chatmode|collection");
	console.log(
		"  path       Path to the item (e.g., prompts/example.prompt.md)",
	);
	console.log("  target     global|workspace|view|ask (default: ask)");
	console.log(
		"  publisher  Your publisher name (default: " + DEFAULT_PUBLISHER + ")",
	);
	console.log("");
	console.log("Examples:");
	console.log("  node generate-link.js prompt prompts/test-gen.prompt.md");
	console.log(
		"  node generate-link.js instruction instructions/java.instructions.md global",
	);
	console.log(
		"  node generate-link.js collection collections/bundle.collection.yml ask",
	);
}

// Parse command line arguments
const args = process.argv.slice(2);

if (args.length === 0 || args.includes("--help") || args.includes("-h")) {
	printUsage();
	process.exit(0);
}

if (args.length < 2) {
	console.error("❌ Error: Missing required parameters\n");
	printUsage();
	process.exit(1);
}

const [type, path, target, publisher] = args;

// Validate type
const validTypes = [
	"instruction",
	"instructions",
	"prompt",
	"prompts",
	"agent",
	"agents",
	"chatmode",
	"chatmodes",
	"collection",
	"collections",
];
if (!validTypes.includes(type.toLowerCase())) {
	console.error(`❌ Error: Invalid type "${type}"`);
	console.error(`   Valid types: ${validTypes.join(", ")}`);
	process.exit(1);
}

// Validate target if provided
if (target) {
	const validTargets = ["global", "workspace", "view", "ask"];
	if (!validTargets.includes(target.toLowerCase())) {
		console.error(`❌ Error: Invalid target "${target}"`);
		console.error(`   Valid targets: ${validTargets.join(", ")}`);
		process.exit(1);
	}
}

// Generate the link
const link = generateLink(type, path, target, publisher);
const filename = path.split("/").pop();

console.log("✅ Generated installation link:\n");
console.log("📋 Raw URL:");
console.log(link);
console.log("");
console.log("📝 Markdown:");
console.log(`[Install ${filename}](${link})`);
console.log("");
console.log("🌐 HTML:");
console.log(`<a href="${link}">Install ${filename}</a>`);
console.log("");
console.log("🎨 HTML Button:");
console.log(
	`<a href="${link}" style="background:#007acc;color:white;padding:8px 16px;text-decoration:none;border-radius:4px;display:inline-block">📥 Install ${filename}</a>`,
);
console.log("");
console.log("🔖 Badge (Shields.io):");
const badgeUrl = `[![Install](https://img.shields.io/badge/Install-VS%20Code-blue)](${link})`;
console.log(badgeUrl);
