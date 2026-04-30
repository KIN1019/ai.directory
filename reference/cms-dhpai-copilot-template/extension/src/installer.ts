/**
 * Installation service for items
 */

import * as vscode from "vscode";
import * as path from "path";
import * as fs from "fs";
import { ItemPickerItem, InstallResult } from "./types";

export class InstallerService {
	/**
	 * Get VS Code user directory
	 */
	private getVSCodeUserDir(): string {
		// Get the global storage path and go two directories up to get User directory
		const homeDir = process.env.HOME || process.env.USERPROFILE || "";

		if (process.platform === "win32") {
			return path.join(homeDir, "AppData", "Roaming", "Code", "User");
		} else if (process.platform === "darwin") {
			return path.join(
				homeDir,
				"Library",
				"Application Support",
				"Code",
				"User",
			);
		} else {
			return path.join(homeDir, ".config", "Code", "User");
		}
	}

	/**
	 * Open content in untitled editor
	 */
	async openInUntitledEditor(
		content: string,
		filename: string,
	): Promise<InstallResult> {
		const language =
			filename.endsWith(".yml") || filename.endsWith(".yaml")
				? "yaml"
				: "markdown";

		try {
			const doc = await vscode.workspace.openTextDocument({
				content,
				language,
			});
			await vscode.window.showTextDocument(doc);
			return { success: true };
		} catch (error) {
			return {
				success: false,
				error: `Failed to open editor: ${error instanceof Error ? error.message : String(error)}`,
			};
		}
	}

	/**
	 * Install globally
	 */
	async installGlobally(
		content: string,
		item: ItemPickerItem,
		category: string,
	): Promise<InstallResult> {
		try {
			const vscodeUserDir = this.getVSCodeUserDir();
			let dirPath: string;

			if (category === "instructions") {
				// Instructions go in .vscode/instructions in user home
				const homeDir = process.env.HOME || process.env.USERPROFILE || "";
				dirPath = path.join(homeDir, ".vscode", "instructions");
			} else if (category === "prompts" || category === "agents") {
				// Prompts and agents go in User/prompts folder
				dirPath = path.join(vscodeUserDir, "prompts");
			} else {
				return {
					success: false,
					error: `Unknown category: ${category}`,
				};
			}

			// Create directory if it doesn't exist
			if (!fs.existsSync(dirPath)) {
				fs.mkdirSync(dirPath, { recursive: true });
			}

			const filePath = path.join(dirPath, item.item.filename);
			fs.writeFileSync(filePath, content, "utf-8");

			vscode.window.showInformationMessage(
				`Installed ${item.item.filename} to ${vscode.env.appName} User/prompts directory`,
			);

			return { success: true, path: filePath };
		} catch (error) {
			const errorMsg = `Failed to install ${item.item.filename}: ${
				error instanceof Error ? error.message : String(error)
			}`;
			vscode.window.showErrorMessage(errorMsg);
			return { success: false, error: errorMsg };
		}
	}

	/**
	 * Install to workspace
	 */
	async installToWorkspace(
		content: string,
		item: ItemPickerItem,
		category: string,
	): Promise<InstallResult> {
		const workspaceFolders = vscode.workspace.workspaceFolders;

		if (!workspaceFolders || workspaceFolders.length === 0) {
			const errorMsg = "No workspace folder open";
			vscode.window.showErrorMessage(errorMsg);
			return { success: false, error: errorMsg };
		}

		try {
			const workspacePath = workspaceFolders[0].uri.fsPath;
			let dirPath: string;

			switch (category) {
				case "instructions":
					dirPath = path.join(workspacePath, ".github", "instructions");
					break;
				case "prompts":
					dirPath = path.join(workspacePath, ".github", "prompts");
					break;
				case "agents":
					dirPath = path.join(workspacePath, ".github", "agents");
					break;
				default:
					return {
						success: false,
						error: `Unknown category: ${category}`,
					};
			}

			// Create directory if it doesn't exist
			if (!fs.existsSync(dirPath)) {
				fs.mkdirSync(dirPath, { recursive: true });
			}

			const filePath = path.join(dirPath, item.item.filename);
			fs.writeFileSync(filePath, content, "utf-8");

			vscode.window.showInformationMessage(
				`Installed ${item.item.filename} to workspace`,
			);

			return { success: true, path: filePath };
		} catch (error) {
			const errorMsg = `Failed to install: ${error instanceof Error ? error.message : String(error)}`;
			vscode.window.showErrorMessage(errorMsg);
			return { success: false, error: errorMsg };
		}
	}

	/**
	 * Install to copilot-instructions.md
	 */
	async installToCopilotInstructions(
		content: string,
		item: ItemPickerItem,
	): Promise<InstallResult> {
		const workspaceFolders = vscode.workspace.workspaceFolders;

		if (!workspaceFolders || workspaceFolders.length === 0) {
			const errorMsg = "No workspace folder open";
			vscode.window.showErrorMessage(errorMsg);
			return { success: false, error: errorMsg };
		}

		try {
			const workspacePath = workspaceFolders[0].uri.fsPath;
			const githubDir = path.join(workspacePath, ".github");
			const filePath = path.join(githubDir, "copilot-instructions.md");

			// Create .github directory if it doesn't exist
			if (!fs.existsSync(githubDir)) {
				fs.mkdirSync(githubDir, { recursive: true });
			}

			// Check if file already exists
			if (fs.existsSync(filePath)) {
				const choice = await vscode.window.showQuickPick(
					[
						{
							label: "Append",
							description: "Add to existing instructions",
							action: "append",
						},
						{
							label: "Replace",
							description: "Overwrite existing instructions",
							action: "replace",
						},
					],
					{
						placeHolder: "How to install to copilot-instructions.md?",
					},
				);

				if (!choice) {
					return { success: false, error: "Cancelled or no choice made" };
				}

				if (choice.action === "append") {
					const existingContent = fs.readFileSync(filePath, "utf-8");
					const newContent = `${existingContent}\n\n${content}`;
					fs.writeFileSync(filePath, newContent, "utf-8");
					vscode.window.showInformationMessage(
						`Appended ${item.item.filename} to copilot-instructions.md`,
					);
					return { success: true, path: filePath, mode: "append" };
				} else {
					fs.writeFileSync(filePath, content, "utf-8");
					vscode.window.showInformationMessage(
						"Replaced copilot-instructions.md",
					);
					return { success: true, path: filePath, mode: "replace" };
				}
			} else {
				// Create new file
				fs.writeFileSync(filePath, content, "utf-8");
				vscode.window.showInformationMessage("Created copilot-instructions.md");
				return { success: true, path: filePath, mode: "create" };
			}
		} catch (error) {
			const errorMsg = `Failed to install: ${error instanceof Error ? error.message : String(error)}`;
			vscode.window.showErrorMessage(errorMsg);
			return { success: false, error: errorMsg };
		}
	}

	/**
	 * Open installed file
	 */
	async openInstalledFile(filePath: string): Promise<void> {
		try {
			const uri = vscode.Uri.file(filePath);
			const doc = await vscode.workspace.openTextDocument(uri);
			await vscode.window.showTextDocument(doc);
		} catch (error) {
			vscode.window.showErrorMessage(
				`Failed to open file: ${error instanceof Error ? error.message : String(error)}`,
			);
		}
	}
}
