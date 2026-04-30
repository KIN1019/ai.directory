/**
 * Configuration Template for Documentation Generation Script
 *
 * Copy this file to your scripts directory and update the values
 * to match your repository structure.
 */

module.exports = {
	/**
	 * Base URL for raw file access on GitHub
	 * Format: https://raw.githubusercontent.com/[ORG]/[REPO]/[BRANCH]
	 *
	 * Example: 'https://raw.githubusercontent.com/myorg/myrepo/main'
	 */
	baseRepoUrl: "https://raw.githubusercontent.com/YOUR-ORG/YOUR-REPO/main",

	/**
	 * Base URL for installation redirects
	 * This is typically a shortlink service or your own redirect handler
	 *
	 * Default: 'https://aka.ms/awesome-copilot/install'
	 */
	baseInstallUrl: "https://aka.ms/awesome-copilot/install",

	/**
	 * Directory configurations
	 * Each entry defines a resource type with its location and metadata
	 */
	directories: {
		/**
		 * Instructions Configuration
		 */
		instructions: {
			dir: "instructions", // Directory containing instruction files
			extension: ".instructions.md", // File extension to scan for
			outputFile: "docs/README.instructions.md", // Output documentation file
			title: "📋 Custom Instructions", // Title for the documentation page
			emoji: "📋", // Emoji icon
			description:
				"Team and project-specific instructions to enhance GitHub Copilot's behavior.",
			uriScheme: "chat-instructions", // VS Code URI scheme
		},

		/**
		 * Prompts Configuration
		 */
		prompts: {
			dir: "prompts",
			extension: ".prompt.md",
			outputFile: "docs/README.prompts.md",
			title: "🎯 Prompt Templates",
			emoji: "🎯",
			description:
				"Reusable prompt templates to accelerate common development tasks.",
			uriScheme: "chat-prompts",
		},

		/**
		 * Chat Modes Configuration
		 */
		chatmodes: {
			dir: "chatmodes",
			extension: ".chatmode.md",
			outputFile: "docs/README.chatmodes.md",
			title: "💬 Chat Modes",
			emoji: "💬",
			description:
				"Specialized chat modes for specific scenarios and personas.",
			uriScheme: "chat-modes",
		},

		/**
		 * Collections Configuration
		 */
		collections: {
			dir: "collections",
			extension: ".collection.yml",
			outputFile: "docs/README.collections.md",
			title: "📦 Collections",
			emoji: "📦",
			description: "Curated collections organized by theme or project.",
			uriScheme: "chat-collections",
		},

		/**
		 * Agents Configuration (Optional)
		 * Remove this section if you don't have agents
		 */
		agents: {
			dir: "agents",
			extension: ".agent.md",
			outputFile: "docs/README.agents.md",
			title: "🤖 Agents",
			emoji: "🤖",
			description: "Autonomous agents for complex workflows.",
			uriScheme: "chat-agents",
		},
	},

	/**
	 * File Patterns to Skip
	 * Files matching these patterns will be ignored
	 */
	skipPatterns: ["TEMPLATE", "README", ".example", ".draft"],

	/**
	 * Badge Configuration
	 * Customize the appearance of install buttons
	 */
	badges: {
		vscode: {
			label: "VS_Code",
			message: "Install",
			color: "0098FF",
			style: "flat-square",
			logo: "visualstudiocode",
			logoColor: "white",
		},
		vscodeInsiders: {
			label: "VS_Code_Insiders",
			message: "Install",
			color: "24bfa5",
			style: "flat-square",
			logo: "visualstudiocode",
			logoColor: "white",
		},
	},

	/**
	 * Usage Instructions per Type
	 * Customize the "How to Use" section for each resource type
	 */
	usageInstructions: {
		instructions: [
			"Copy these instructions to your `.github/copilot-instructions.md` file",
			"Create task-specific `.instructions.md` files in `.github/instructions`",
			"Instructions automatically apply once installed in your workspace",
		],
		prompts: [
			"Prompts can be invoked using `#` followed by the prompt name",
			"Use prompts to accelerate common development tasks",
			"Customize prompts for your specific project needs",
		],
		chatmodes: [
			"Chat modes configure Copilot for specific scenarios",
			"Activate a chat mode to change behavior and persona",
			"Use different modes for different development tasks",
		],
		collections: [
			"Collections bundle related instructions, prompts, and chat modes",
			"Install entire collections to quickly configure Copilot",
			"Collections can be customized and extended",
		],
		agents: [
			"Install agents to enable autonomous task execution",
			"Agents can perform complex workflows automatically",
			"Configure agents for your specific scenarios",
		],
	},

	/**
	 * Output Options
	 */
	output: {
		includeTimestamp: true, // Add generation timestamp to files
		includeTOC: false, // Add table of contents
		sortAlphabetically: true, // Sort items alphabetically by title
		includeFileSize: false, // Show file size in documentation
		includeLastModified: false, // Show last modified date
	},
};
