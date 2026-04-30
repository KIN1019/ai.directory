/**
 * Collection handling service
 */

import * as vscode from "vscode";
import * as path from "path";
import { ContentFetcher } from "./fetcher";
import { InstallerService } from "./installer";
import { CollectionItem, ItemPickerItem } from "./types";

export class CollectionService {
	private fetcher: ContentFetcher;
	private installer: InstallerService;

	constructor(fetcher: ContentFetcher, installer: InstallerService) {
		this.fetcher = fetcher;
		this.installer = installer;
	}

	/**
	 * Parse YAML collection content
	 */
	parseCollectionYaml(yamlContent: string): CollectionItem[] {
		try {
			const lines = yamlContent.split("\n");

			// Find the items section
			const itemsStartIdx = lines.findIndex((line) =>
				line.trim().startsWith("items:"),
			);

			if (itemsStartIdx === -1) {
				return [];
			}

			// Extract items section lines
			const itemsSection = lines.slice(itemsStartIdx + 1).filter((line) => {
				const trimmed = line.trim();
				return trimmed && (line.startsWith(" ") || line.startsWith("\t"));
			});

			// Parse each item
			const items: CollectionItem[] = [];
			let currentItem: CollectionItem | null = null;

			for (const line of itemsSection) {
				const trimmed = line.trim();

				if (trimmed.startsWith("- path:")) {
					if (currentItem) {
						items.push(currentItem);
					}
					const pathValue = trimmed.replace(/^-\s*path:\s*/, "").trim();
					currentItem = { path: pathValue };
				} else if (trimmed.startsWith("kind:") && currentItem) {
					const kindValue = trimmed.replace(/^kind:\s*/, "").trim();
					currentItem.kind = kindValue;
				}
			}

			// Add the last item
			if (currentItem) {
				items.push(currentItem);
			}

			return items;
		} catch (error) {
			console.error("Error parsing YAML:", error);
			return [];
		}
	}

	/**
	 * Get category from kind
	 */
	private getCategoryFromKind(kind?: string): string | null {
		switch (kind) {
			case "prompt":
				return "prompts";
			case "instruction":
				return "instructions";
			case "chat-mode":
			case "agent":
				return "agents";
			default:
				return null;
		}
	}

	/**
	 * Get category from path
	 */
	private getCategoryFromPath(itemPath: string): string | null {
		if (itemPath.includes("prompts/")) {
			return "prompts";
		}
		if (itemPath.includes("instructions/")) {
			return "instructions";
		}
		if (itemPath.includes("chatmodes/") || itemPath.includes("agents/")) {
			return "agents";
		}
		return null;
	}

	/**
	 * Install a single collection item
	 */
	private async installCollectionItem(
		item: CollectionItem,
		installGlobally: boolean,
	): Promise<{ success: boolean; error?: string }> {
		try {
			const content = await this.fetcher.fetchContent(item.path);
			const filename = path.basename(item.path);
			const category =
				this.getCategoryFromKind(item.kind) ||
				this.getCategoryFromPath(item.path);

			if (!category) {
				return {
					success: false,
					error: `Unknown category for ${item.path} (kind: ${item.kind})`,
				};
			}

			const itemObj: ItemPickerItem = {
				label: filename,
				description: "",
				detail: "",
				item: { title: filename, description: "", filename, link: item.path },
				iconPath: new vscode.ThemeIcon("copilot"),
			};

			const result = installGlobally
				? await this.installer.installGlobally(content, itemObj, category)
				: await this.installer.installToWorkspace(content, itemObj, category);

			return result;
		} catch (error) {
			return {
				success: false,
				error: error instanceof Error ? error.message : String(error),
			};
		}
	}

	/**
	 * Install all items in a collection
	 */
	async installAllCollectionItems(
		collectionContent: string,
		installGlobally: boolean,
	): Promise<{ installed: number; failed: number }> {
		const items = this.parseCollectionYaml(collectionContent);

		if (items.length === 0) {
			vscode.window.showErrorMessage("No items found in collection");
			return { installed: 0, failed: 0 };
		}

		let installed = 0;
		let failed = 0;

		await vscode.window.withProgress(
			{
				location: vscode.ProgressLocation.Notification,
				title: "Installing collection items",
				cancellable: false,
			},
			async (progress) => {
				for (let i = 0; i < items.length; i++) {
					const item = items[i];
					const percentage = ((i + 1) / items.length) * 100;

					progress.report({
						message: `Installing ${i + 1}/${items.length}: ${path.basename(item.path)}`,
						increment: percentage,
					});

					const result = await this.installCollectionItem(
						item,
						installGlobally,
					);

					if (result.success) {
						installed++;
						console.log("Successfully installed:", item.path);
					} else {
						failed++;
						console.error("Failed to install:", item.path, result.error);
					}
				}
			},
		);

		vscode.window.showInformationMessage(
			`Collection installation complete: installed ${installed} items${failed > 0 ? `, ${failed} failed` : ""}`,
		);

		return { installed, failed };
	}
}
