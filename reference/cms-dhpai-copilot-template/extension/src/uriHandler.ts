/**
 * URI Handler for vscode:// protocol links
 * Handles both OAuth callbacks and direct installation links
 */

import * as vscode from "vscode";
import { GitHubEnterpriseAuth } from "./auth";
import { ContentFetcher } from "./fetcher";
import { InstallerService } from "./installer";
import { CollectionService } from "./collections";
import { ItemPickerItem } from "./types";

export class URIHandler implements vscode.UriHandler {
	private auth: GitHubEnterpriseAuth;
	private fetcher: ContentFetcher;
	private installer: InstallerService;
	private collectionService: CollectionService;

	constructor(
		auth: GitHubEnterpriseAuth,
		fetcher: ContentFetcher,
		installer: InstallerService,
		collectionService: CollectionService,
	) {
		this.auth = auth;
		this.fetcher = fetcher;
		this.installer = installer;
		this.collectionService = collectionService;
	}

	/**
	 * Handle incoming vscode:// URIs
	 */
	async handleUri(uri: vscode.Uri): Promise<void> {
		console.log("🔗 Received URI:", uri.toString());
		console.log("   Path:", uri.path);
		console.log("   Query:", uri.query);

		try {
			// Handle OAuth callback
			if (uri.path === "/auth-callback") {
				console.log("📥 Handling OAuth callback");
				await this.handleOAuthCallback(uri);
				return;
			}

			// Handle installation link
			if (uri.path === "/install") {
				console.log("📦 Handling installation link");
				await this.handleInstallLink(uri);
				return;
			}

			// Unknown path
			console.warn("⚠️ Unknown URI path:", uri.path);
			vscode.window.showWarningMessage(`Unknown URI path: ${uri.path}`);
		} catch (error) {
			console.error("❌ Error handling URI:", error);
			vscode.window.showErrorMessage(
				`Failed to handle URI: ${error instanceof Error ? error.message : String(error)}`,
			);
		}
	}

	/**
	 * Handle OAuth callback
	 */
	private async handleOAuthCallback(uri: vscode.Uri): Promise<void> {
		const query = new URLSearchParams(uri.query);
		const code = query.get("code");
		const state = query.get("state");

		if (code && state) {
			// Delegate to auth service
			await this.auth.handleOAuthCallback(code, state);
		}
	}

	/**
	 * Handle direct installation link
	 * Format: vscode://publisher.dhpai/install?type=prompt&link=prompts/example.prompt.md&target=global
	 */
	private async handleInstallLink(uri: vscode.Uri): Promise<void> {
		try {
			const query = new URLSearchParams(uri.query);
			const type = query.get("type"); // instruction, prompt, agent, collection
			const link = query.get("link"); // path to the item
			const target = query.get("target") || "ask"; // global, workspace, or ask

			console.log("📋 Install parameters:", { type, link, target });

			if (!type || !link) {
				console.error("❌ Missing parameters - type:", type, "link:", link);
				vscode.window.showErrorMessage(
					"Invalid installation link. Missing type or link parameter.",
				);
				return;
			}

			console.log("✅ Parameters valid, starting installation...");

			// Ensure user is authenticated
			console.log("🔐 Checking authentication...");
			if (!(await this.auth.ensureAuthenticated())) {
				console.log("❌ Authentication failed or cancelled");
				return;
			}
			console.log("✅ Authenticated");

			// Show progress
			await vscode.window.withProgress(
				{
					location: vscode.ProgressLocation.Notification,
					title: "Installing from link...",
					cancellable: false,
				},
				async (progress) => {
					progress.report({ message: "Fetching content..." });
					console.log("📥 Fetching content from:", link);

					// Fetch content
					const content = await this.fetcher.fetchContent(link);
					console.log("✅ Content fetched, length:", content.length);
					const filename = link.split("/").pop() || "item";
					console.log("📄 Filename:", filename);

					// Create item object
					const item: ItemPickerItem = {
						label: filename,
						description: `Installing from link`,
						detail: link,
						item: {
							title: filename,
							description: "Installed via vscode:// link",
							filename: filename,
							link: link,
						},
						iconPath: new vscode.ThemeIcon("copilot"),
					};

					progress.report({ message: "Installing..." });
					console.log("📦 Determining installation target...");

					// Determine installation target
					let installTarget: "global" | "workspace" | "view" = "global";

					if (target === "ask") {
						console.log("❓ Asking user for installation target...");
						const choice = await vscode.window.showQuickPick(
							[
								{
									label: "$(globe) Install Globally",
									description: "Available in all workspaces",
									value: "global" as const,
								},
								{
									label: "$(github-project) Install to Workspace",
									description: "Only in current workspace",
									value: "workspace" as const,
								},
								{
									label: "$(preview) View Content",
									description: "Open in editor without installing",
									value: "view" as const,
								},
							],
							{
								placeHolder: `Where do you want to install ${filename}?`,
								ignoreFocusOut: true,
							},
						);

						if (!choice) {
							console.log("❌ User cancelled installation target selection");
							return;
						}
						installTarget = choice.value;
						console.log("✅ User selected:", installTarget);
					} else if (
						target === "workspace" ||
						target === "global" ||
						target === "view"
					) {
						installTarget = target;
						console.log("✅ Target from parameter:", installTarget);
					}

					// Handle collection differently
					if (type === "collection") {
						console.log("📦 Processing collection...");
						if (installTarget === "view") {
							console.log("👁️ Opening collection in editor...");
							await this.installer.openInUntitledEditor(content, filename);
							vscode.window.showInformationMessage(
								`Opened collection: ${filename}`,
							);
						} else {
							console.log("📦 Installing collection items...");
							const result =
								await this.collectionService.installAllCollectionItems(
									content,
									installTarget === "global",
								);
							console.log("✅ Collection installed:", result);
							vscode.window.showInformationMessage(
								`Installed collection: ${result.installed} items`,
							);
						}
						return;
					}

					// Install based on target
					console.log("🎯 Installing to:", installTarget);
					let result;

					if (installTarget === "view") {
						console.log("👁️ Opening in editor...");
						result = await this.installer.openInUntitledEditor(
							content,
							filename,
						);
						console.log("✅ Opened in editor");
						vscode.window.showInformationMessage(`Opened ${type}: ${filename}`);
					} else if (installTarget === "global") {
						console.log("🌍 Installing globally...");
						const category = this.getCategoryFromType(type);
						console.log("   Category:", category);
						result = await this.installer.installGlobally(
							content,
							item,
							category,
						);
						console.log("   Result:", result);
						if (result.success && result.path) {
							console.log("✅ Installed, opening file:", result.path);
							await this.installer.openInstalledFile(result.path);
							vscode.window.showInformationMessage(
								`✅ Installed ${type} globally: ${filename}`,
							);
						} else {
							console.error("❌ Installation failed:", result.error);
						}
					} else {
						console.log("📁 Installing to workspace...");
						// Workspace installation
						const category = this.getCategoryFromType(type);

						// Special handling for instructions
						if (type === "instruction") {
							const choice = await vscode.window.showQuickPick(
								[
									{
										label: "GitHub Instructions Directory",
										description: ".github/instructions/",
										value: "directory",
									},
									{
										label: "Copilot Instructions File",
										description: ".github/copilot-instructions.md",
										value: "file",
									},
								],
								{
									placeHolder: "Where to install?",
									ignoreFocusOut: true,
								},
							);

							if (!choice) {
								return;
							}

							if (choice.value === "file") {
								result = await this.installer.installToCopilotInstructions(
									content,
									item,
								);
							} else {
								result = await this.installer.installToWorkspace(
									content,
									item,
									category,
								);
							}
						} else {
							result = await this.installer.installToWorkspace(
								content,
								item,
								category,
							);
						}

						if (result.success && result.path) {
							await this.installer.openInstalledFile(result.path);
							vscode.window.showInformationMessage(
								`✅ Installed ${type} to workspace: ${filename}`,
							);
						}
					}
				},
			);
		} catch (error) {
			vscode.window.showErrorMessage(
				`Failed to install from link: ${error instanceof Error ? error.message : String(error)}`,
			);
			console.error("Install from link error:", error);
		}
	}

	/**
	 * Convert type parameter to category
	 */
	private getCategoryFromType(type: string): string {
		const typeMap: Record<string, string> = {
			instruction: "instructions",
			instructions: "instructions",
			prompt: "prompts",
			prompts: "prompts",
			agent: "agents",
			agents: "agents",
			chatmode: "agents",
			chatmodes: "agents",
			collection: "collections",
			collections: "collections",
		};
		return typeMap[type.toLowerCase()] || "prompts";
	}
}
