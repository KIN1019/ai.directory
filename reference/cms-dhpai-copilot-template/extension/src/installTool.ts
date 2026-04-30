/**
 * Language Model Tool for installing DHPAI resources
 */

import * as vscode from "vscode";
import { ContentFetcher } from "./fetcher";
import { InstallerService } from "./installer";
import { IndexData, IndexItem, ItemPickerItem } from "./types";

interface InstallParameters {
	resources: string | string[];
	target?: "global" | "workspace" | "copilot-instructions";
	category?: string;
}

interface InstallResultSummary {
	successful: string[];
	failed: { resource: string; error: string }[];
}

export class DHPAIInstallTool {
	private fetcher: ContentFetcher;
	private installer: InstallerService;
	private cachedIndex: IndexData | null = null;
	private cacheTimestamp: number = 0;
	private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

	constructor(fetcher: ContentFetcher, installer: InstallerService) {
		this.fetcher = fetcher;
		this.installer = installer;
	}

	/**
	 * Register the install tool with VS Code Language Model API
	 */
	register(context: vscode.ExtensionContext): vscode.Disposable {
		const self = this;
		return vscode.lm.registerTool("install_dhpaiResources", {
			async invoke(
				options: vscode.LanguageModelToolInvocationOptions<InstallParameters>,
				token: vscode.CancellationToken,
			) {
				try {
					const parameters = options.input;
					const result = await self.installResources(parameters, token);
					const formattedResult = self.formatResult(result);

					return new vscode.LanguageModelToolResult([
						new vscode.LanguageModelTextPart(formattedResult),
					]);
				} catch (error) {
					const errorMessage =
						error instanceof Error ? error.message : String(error);
					return new vscode.LanguageModelToolResult([
						new vscode.LanguageModelTextPart(
							`Error installing DHPAI resources: ${errorMessage}`,
						),
					]);
				}
			},

			async prepareInvocation(
				options: vscode.LanguageModelToolInvocationPrepareOptions<InstallParameters>,
				token: vscode.CancellationToken,
			) {
				const { resources, target = "workspace" } = options.input;
				const resourceArray = Array.isArray(resources)
					? resources
					: [resources];
				const count = resourceArray.length;
				const targetText =
					target === "global"
						? "globally"
						: target === "copilot-instructions"
							? "to Copilot instructions"
							: "to workspace";

				return {
					invocationMessage: `Installing ${count} resource(s) ${targetText}...`,
					confirmationMessages: {
						title: "Install DHPAI Resources",
						message: new vscode.MarkdownString(
							`Install ${count} resource(s) ${targetText}?\n\n` +
								`Resources:\n${resourceArray.map((r) => `- \`${r}\``).join("\n")}`,
						),
					},
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
	 * Find a resource by filename or link
	 */
	private async findResource(
		identifier: string,
		token?: vscode.CancellationToken,
	): Promise<{ item: IndexItem; category: string } | null> {
		const index = await this.getIndex(token);
		const categories = [
			"instructions",
			"prompts",
			"agents",
			"collections",
		] as const;

		for (const category of categories) {
			const items = index[category] || [];
			const item = items.find(
				(i) =>
					i.filename === identifier ||
					i.link === identifier ||
					i.title === identifier,
			);

			if (item) {
				return { item, category };
			}
		}

		return null;
	}

	/**
	 * Install multiple resources
	 */
	private async installResources(
		parameters: InstallParameters,
		token?: vscode.CancellationToken,
	): Promise<InstallResultSummary> {
		const {
			resources,
			target = "workspace",
			category: categoryFilter,
		} = parameters;
		const resourceArray = Array.isArray(resources) ? resources : [resources];

		const result: InstallResultSummary = {
			successful: [],
			failed: [],
		};

		for (const resourceId of resourceArray) {
			if (token?.isCancellationRequested) {
				break;
			}

			try {
				// Find the resource
				const found = await this.findResource(resourceId, token);

				if (!found) {
					result.failed.push({
						resource: resourceId,
						error: "Resource not found",
					});
					continue;
				}

				const { item, category } = found;

				// Check category filter if provided
				if (categoryFilter && category !== categoryFilter) {
					result.failed.push({
						resource: resourceId,
						error: `Resource is in '${category}' category, but filter requires '${categoryFilter}'`,
					});
					continue;
				}

				// Fetch content
				const content = await this.fetcher.fetchContent(item.link);

				// Create ItemPickerItem for installer
				const pickerItem: ItemPickerItem = {
					label: item.title,
					description: item.description,
					detail: item.filename,
					item: item,
					iconPath: { id: "file" },
				};

				// Install based on target
				let installResult;
				if (target === "global") {
					installResult = await this.installer.installGlobally(
						content,
						pickerItem,
						category,
					);
				} else if (target === "copilot-instructions") {
					installResult = await this.installer.installToCopilotInstructions(
						content,
						pickerItem,
					);
				} else {
					// workspace
					installResult = await this.installer.installToWorkspace(
						content,
						pickerItem,
						category,
					);
				}

				if (installResult.success) {
					result.successful.push(`${item.title} (${item.filename})`);
				} else {
					result.failed.push({
						resource: resourceId,
						error: installResult.error || "Unknown error",
					});
				}
			} catch (error) {
				result.failed.push({
					resource: resourceId,
					error: error instanceof Error ? error.message : String(error),
				});
			}
		}

		return result;
	}

	/**
	 * Format installation result for display
	 */
	private formatResult(result: InstallResultSummary): string {
		const parts: string[] = [];

		if (result.successful.length > 0) {
			parts.push(
				`✅ Successfully installed ${result.successful.length} resource(s):`,
			);
			parts.push("");
			result.successful.forEach((name) => {
				parts.push(`  • ${name}`);
			});
		}

		if (result.failed.length > 0) {
			if (parts.length > 0) {
				parts.push("");
			}
			parts.push(`❌ Failed to install ${result.failed.length} resource(s):`);
			parts.push("");
			result.failed.forEach(({ resource, error }) => {
				parts.push(`  • ${resource}: ${error}`);
			});
		}

		if (result.successful.length === 0 && result.failed.length === 0) {
			return "No resources were processed.";
		}

		return parts.join("\n");
	}

	/**
	 * Clear the cache
	 */
	clearCache(): void {
		this.cachedIndex = null;
		this.cacheTimestamp = 0;
	}
}
