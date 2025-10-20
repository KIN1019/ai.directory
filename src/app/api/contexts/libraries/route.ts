import { NextResponse } from "next/server";
import fs from "fs";
import path from "path";
import yaml from "js-yaml";

export const dynamic = "force-dynamic";

interface LibraryMetadata {
	name: string;
	description: string;
	slug: string;
	llmsTxtUrl?: string;
	source?: string;
	lastUpdated?: string;
	techStacks?: string[];
	teams?: string[];
	categories?: string[];
}

const DHP_AI_CODE_CONTEXT_BASE_URL = "https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk";

/**
 * Infer the llms.txt URL from the source repository
 * Uses DHP AI Code Context API: /{org}/{repo}/llms.txt
 * 
 * @param source - Repository source in format: /owner/repo or https://github.com/owner/repo
 * @returns Full URL to llms.txt endpoint
 */
function inferLlmsTxtUrl(source?: string): string | undefined {
	if (!source) return undefined;

	let owner: string | undefined;
	let repo: string | undefined;

	// If source is already a full URL, extract owner/repo from it
	if (source.startsWith("http://") || source.startsWith("https://")) {
		// Extract owner/repo from GitHub URLs
		const githubMatch = source.match(/github\.com\/([^\/]+)\/([^\/\?#]+)/);
		if (githubMatch) {
			[, owner, repo] = githubMatch;
		} else {
			return undefined;
		}
	}
	// If source is in /owner/repo format
	else if (source.startsWith("/")) {
		const parts = source.split("/").filter(Boolean);
		if (parts.length >= 2) {
			[owner, repo] = parts;
		} else {
			return undefined;
		}
	} else {
		return undefined;
	}

	if (!owner || !repo) return undefined;

	// Use DHP AI Code Context API format: /{org}/{repo}/llms.txt
	return `${DHP_AI_CODE_CONTEXT_BASE_URL}/${owner}/${repo}/llms.txt`;
}

export async function GET() {
	try {
		const contextsDir = path.join(process.cwd(), "resources", "contexts");
		const entries = fs.readdirSync(contextsDir, { withFileTypes: true });

		const libraries: LibraryMetadata[] = [];

		for (const entry of entries) {
			if (!entry.isDirectory()) continue;

			const metaPath = path.join(contextsDir, entry.name, "_meta.yaml");
			if (!fs.existsSync(metaPath)) continue;

			try {
				const content = fs.readFileSync(metaPath, "utf8");
				const data = yaml.load(content) as LibraryMetadata;

				// Infer llms.txt URL if not explicitly set
				if (!data.llmsTxtUrl && data.source) {
					data.llmsTxtUrl = inferLlmsTxtUrl(data.source);
				}

				libraries.push(data);
			} catch (err) {
				console.error(`Error parsing ${entry.name}/_meta.yaml:`, err);
			}
		}

		return NextResponse.json({ libraries });
	} catch (error) {
		console.error("Error loading libraries:", error);
		return NextResponse.json(
			{ error: "Failed to load libraries" },
			{ status: 500 },
		);
	}
}

