/**
 * Language Model Tool for searching DHPAI resources
 */

import * as vscode from "vscode";
import { ContentFetcher } from "./fetcher";
import { IndexData, IndexItem } from "./types";

interface SearchResult {
	title: string;
	description: string;
	category: string;
	filename: string;
}

interface SearchParameters {
	query?: string;
	category?: string;
	limit?: number;
}

export class DHPAISearchTool {
	private fetcher: ContentFetcher;
	private cachedIndex: IndexData | null = null;
	private cacheTimestamp: number = 0;
	private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

	constructor(fetcher: ContentFetcher) {
		this.fetcher = fetcher;
	}

	/**
	 * Register the search tool with VS Code Language Model API
	 */
	register(context: vscode.ExtensionContext): vscode.Disposable {
		const self = this;
		return vscode.lm.registerTool("search_dhpaiResources", {
			async invoke(
				options: vscode.LanguageModelToolInvocationOptions<SearchParameters>,
				token: vscode.CancellationToken,
			) {
				try {
					const parameters = options.input;
					const results = await self.search(parameters, token);
					const formattedResults = self.formatResults(results);

					return new vscode.LanguageModelToolResult([
						new vscode.LanguageModelTextPart(formattedResults),
					]);
				} catch (error) {
					const errorMessage =
						error instanceof Error ? error.message : String(error);
					return new vscode.LanguageModelToolResult([
						new vscode.LanguageModelTextPart(
							`Error searching DHPAI resources: ${errorMessage}`,
						),
					]);
				}
			},

			async prepareInvocation(
				options: vscode.LanguageModelToolInvocationPrepareOptions<SearchParameters>,
				token: vscode.CancellationToken,
			) {
				const { query, category } = options.input;
				const message = category
					? `Searching ${category} for "${query || "all items"}"...`
					: `Searching all DHPAI resources for "${query || "all items"}"...`;

				return {
					invocationMessage: message,
				};
			},
		});
	}

	/**
	 * Get index data with caching
	 */
	private async getIndex(token?: vscode.CancellationToken): Promise<IndexData> {
		const now = Date.now();

		// Return cached data if still valid
		if (this.cachedIndex && now - this.cacheTimestamp < this.CACHE_TTL) {
			return this.cachedIndex;
		}

		// Fetch fresh data
		try {
			this.cachedIndex = await this.fetcher.fetchIndex();
			this.cacheTimestamp = now;
			return this.cachedIndex;
		} catch (error) {
			// If fetch fails but we have cached data, return it
			if (this.cachedIndex) {
				console.warn("Failed to fetch fresh index, using cached data", error);
				return this.cachedIndex;
			}
			throw error;
		}
	}

	/**
	 * Perform the search
	 */
	private async search(
		parameters: SearchParameters,
		token?: vscode.CancellationToken,
	): Promise<SearchResult[]> {
		const { query = "", category, limit = 10 } = parameters;

		// Get index data
		const index = await this.getIndex(token);

		// Collect items from specified category or all categories
		const items: SearchResult[] = [];
		const categories = category
			? [category]
			: ["instructions", "prompts", "agents", "collections"];

		for (const cat of categories) {
			const categoryItems = index[cat as keyof IndexData] || [];
			for (const item of categoryItems) {
				items.push({
					title: item.title,
					description: item.description,
					category: cat,
					filename: item.filename,
				});
			}
		}

		// Filter by query if provided
		let filteredItems = items;
		if (query && query.trim()) {
			const searchTerms = query.toLowerCase().split(/\s+/);
			filteredItems = items.filter((item) => {
				const searchableText =
					`${item.title} ${item.description}`.toLowerCase();
				return searchTerms.every((term) => searchableText.includes(term));
			});
		}

		// Sort by relevance (title matches first, then description matches)
		if (query && query.trim()) {
			const queryLower = query.toLowerCase();
			filteredItems.sort((a, b) => {
				const aInTitle = a.title.toLowerCase().includes(queryLower);
				const bInTitle = b.title.toLowerCase().includes(queryLower);
				if (aInTitle && !bInTitle) return -1;
				if (!aInTitle && bInTitle) return 1;
				return 0;
			});
		}

		// Apply limit
		return filteredItems.slice(0, limit);
	}

	/**
	 * Format search results for display
	 */
	private formatResults(results: SearchResult[]): string {
		if (results.length === 0) {
			return "No resources found matching your search criteria.";
		}

		const formattedResults = results
			.map((result, index) => {
				return `${index + 1}. **${result.title}** (${result.category})
   Description: ${result.description}
   File: ${result.filename}`;
			})
			.join("\n\n");

		return `Found ${results.length} resource(s):\n\n${formattedResults}`;
	}

	/**
	 * Clear the cache (useful for testing or manual refresh)
	 */
	clearCache(): void {
		this.cachedIndex = null;
		this.cacheTimestamp = 0;
	}
}
