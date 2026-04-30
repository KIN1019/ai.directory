/**
 * Main extension entry point
 */

import * as vscode from "vscode";
import { GitHubEnterpriseAuth } from "./auth";
import { ContentFetcher } from "./fetcher";
import { PreferencesManager } from "./preferences";
import { UIPickerService } from "./pickers";
import { InstallerService } from "./installer";
import { CollectionService } from "./collections";
import { URIHandler } from "./uriHandler";
import { DHPAISearchTool } from "./searchTool";
import { DHPAIInstallTool } from "./installTool";
import { ItemPickerItem } from "./types";

let auth: GitHubEnterpriseAuth;
let fetcher: ContentFetcher;
let prefsManager: PreferencesManager;
let pickerService: UIPickerService;
let installer: InstallerService;
let collectionService: CollectionService;
let uriHandler: URIHandler;
let searchTool: DHPAISearchTool;
let installTool: DHPAIInstallTool;

export function activate(context: vscode.ExtensionContext): void {
	console.log("DHPAI extension is now active");

	// Initialize services
	auth = new GitHubEnterpriseAuth(context);
	fetcher = new ContentFetcher(auth);
	prefsManager = new PreferencesManager(context);
	pickerService = new UIPickerService(prefsManager);
	installer = new InstallerService();
	collectionService = new CollectionService(fetcher, installer);

	// Initialize authentication context (don't await in activate, but ensure it runs)
	updateAuthContext().catch((error) => {
		console.error("Failed to update auth context:", error);
	});

	// Initialize and register URI handler
	uriHandler = new URIHandler(auth, fetcher, installer, collectionService);
	context.subscriptions.push(vscode.window.registerUriHandler(uriHandler));

	// Initialize and register Language Model Tools for AI
	searchTool = new DHPAISearchTool(fetcher);
	installTool = new DHPAIInstallTool(fetcher, installer);

	try {
		const searchDisposable = searchTool.register(context);
		context.subscriptions.push(searchDisposable);
		console.log("DHPAI search tool registered successfully");
	} catch (error) {
		console.error("Failed to register DHPAI search tool:", error);
		vscode.window.showWarningMessage(
			"DHPAI: Search tool registration failed. Language model features may not be available.",
		);
	}

	try {
		const installDisposable = installTool.register(context);
		context.subscriptions.push(installDisposable);
		console.log("DHPAI install tool registered successfully");
	} catch (error) {
		console.error("Failed to register DHPAI install tool:", error);
		vscode.window.showWarningMessage(
			"DHPAI: Install tool registration failed. Some language model features may not be available.",
		);
	}

	// Register explore command
	const exploreCommand = vscode.commands.registerCommand(
		"dhpai.explore",
		async () => {
			await exploreAndInstall();
		},
	);

	// Register login command
	const loginCommand = vscode.commands.registerCommand(
		"dhpai.login",
		async () => {
			const success = await auth.login();
			if (success) {
				await updateAuthContext();
			}
		},
	);

	// Register logout command
	const logoutCommand = vscode.commands.registerCommand(
		"dhpai.logout",
		async () => {
			await auth.logout();
			await updateAuthContext();
		},
	);

	// Register command to clear tool caches
	const clearCacheCommand = vscode.commands.registerCommand(
		"dhpai.clearCache",
		() => {
			searchTool.clearCache();
			installTool.clearCache();
			vscode.window.showInformationMessage("DHPAI: Tool caches cleared");
		},
	);

	// Debug command to check auth status
	const checkAuthCommand = vscode.commands.registerCommand(
		"dhpai.checkAuth",
		async () => {
			const isAuth = await auth.isAuthenticated();
			const token = await auth.getToken();
			vscode.window.showInformationMessage(
				`DHPAI Auth Status: ${isAuth ? "Authenticated" : "Not Authenticated"}${token ? ` (token length: ${token.length})` : ""}`,
			);
			console.log("DHPAI: Auth status:", isAuth, "Token exists:", !!token);
		},
	);

	context.subscriptions.push(
		exploreCommand,
		loginCommand,
		logoutCommand,
		clearCacheCommand,
		checkAuthCommand,
	);
}

/**
 * Update authentication context for command visibility
 */
async function updateAuthContext(): Promise<void> {
	const isAuthenticated = await auth.isAuthenticated();
	console.log("DHPAI: Setting authentication context to:", isAuthenticated);
	await vscode.commands.executeCommand(
		"setContext",
		"dhpai.isAuthenticated",
		isAuthenticated,
	);
}

export function deactivate(): void {
	// Cleanup if needed
}

/**
 * Main flow: explore and install items
 */
async function exploreAndInstall(): Promise<void> {
	try {
		// Ensure user is authenticated
		if (!(await auth.ensureAuthenticated())) {
			return;
		}

		// Update context after successful authentication
		await updateAuthContext();

		// Fetch index
		const index = await vscode.window.withProgress(
			{
				location: vscode.ProgressLocation.Notification,
				title: "Fetching DHPAI index...",
				cancellable: false,
			},
			async () => {
				return await fetcher.fetchIndex();
			},
		);

		// Show category picker
		const category = await pickerService.showCategoryPicker();
		if (!category) {
			return;
		}

		// Show item picker
		const item = await pickerService.showItemPicker(index, category.category);
		if (!item) {
			return;
		}

		// Show action picker
		const action = await pickerService.showActionPicker(
			item,
			category.category,
		);
		if (!action) {
			return;
		}

		// Execute action
		await executeAction(item, action.action, category.category);
	} catch (error) {
		vscode.window.showErrorMessage(
			`Error: ${error instanceof Error ? error.message : String(error)}`,
		);
		console.error("Error in dhpai:", error);
	}
}

/**
 * Execute the selected action
 */
async function executeAction(
	item: ItemPickerItem,
	actionType: string,
	category: string,
): Promise<void> {
	// Fetch content
	const content = await vscode.window.withProgress(
		{
			location: vscode.ProgressLocation.Notification,
			title: `Fetching ${item.item.filename}...`,
			cancellable: false,
		},
		async () => {
			return await fetcher.fetchContent(item.item.link);
		},
	);

	switch (actionType) {
		case "view":
			await installer.openInUntitledEditor(content, item.item.filename);
			break;

		case "global": {
			const result = await installer.installGlobally(content, item, category);
			if (result.success && result.path) {
				await installer.openInstalledFile(result.path);
			}
			break;
		}

		case "workspace": {
			if (category === "instructions") {
				// Show choice for instructions
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
					},
				);

				if (!choice) {
					return;
				}

				if (choice.value === "file") {
					const result = await installer.installToCopilotInstructions(
						content,
						item,
					);
					if (result.success && result.path) {
						await installer.openInstalledFile(result.path);
					}
				} else {
					const result = await installer.installToWorkspace(
						content,
						item,
						category,
					);
					if (result.success && result.path) {
						await installer.openInstalledFile(result.path);
					}
				}
			} else {
				const result = await installer.installToWorkspace(
					content,
					item,
					category,
				);
				if (result.success && result.path) {
					await installer.openInstalledFile(result.path);
				}
			}
			break;
		}

		case "install-all-global":
			await collectionService.installAllCollectionItems(content, true);
			break;

		case "install-all-workspace":
			await collectionService.installAllCollectionItems(content, false);
			break;

		default:
			vscode.window.showErrorMessage(`Unknown action: ${actionType}`);
	}
}
