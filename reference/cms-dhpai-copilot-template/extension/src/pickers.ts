/**
 * UI pickers with memory
 */

import * as vscode from "vscode";
import { PreferencesManager } from "./preferences";
import {
	CategoryItem,
	ItemPickerItem,
	ActionItem,
	IndexItem,
	IndexData,
} from "./types";

export class UIPickerService {
	private prefsManager: PreferencesManager;

	constructor(prefsManager: PreferencesManager) {
		this.prefsManager = prefsManager;
	}

	/**
	 * Show picker with memory of last selection
	 */
	private async showPickerWithMemory<T extends vscode.QuickPickItem>(
		items: T[],
		options: {
			title: string;
			placeholder: string;
			preferenceKey: string;
			matchFn: (item: T, lastChoice: unknown) => boolean;
			saveFn: (item: T) => unknown;
		},
	): Promise<T | undefined> {
		const lastChoice = this.prefsManager.getPreference(
			options.preferenceKey,
			null,
		);

		return new Promise<T | undefined>((resolve) => {
			const picker = vscode.window.createQuickPick<T>();
			picker.items = items;
			picker.title = options.title;
			picker.placeholder = options.placeholder;
			picker.ignoreFocusOut = true;
			picker.matchOnDescription = true;
			picker.matchOnDetail = true;

			// Set active item based on last choice
			if (lastChoice) {
				const activeIndex = items.findIndex((item) =>
					options.matchFn(item, lastChoice),
				);
				if (activeIndex >= 0) {
					picker.activeItems = [items[activeIndex]];
				}
			}

			picker.onDidAccept(() => {
				const selected = picker.selectedItems[0];
				picker.hide();
				if (selected) {
					void this.prefsManager.savePreference(
						options.preferenceKey,
						options.saveFn(selected),
					);
					resolve(selected);
				} else {
					resolve(undefined);
				}
			});

			picker.onDidHide(() => {
				resolve(undefined);
				picker.dispose();
			});

			picker.show();
		});
	}

	/**
	 * Show category picker
	 */
	async showCategoryPicker(): Promise<CategoryItem | undefined> {
		const categories: CategoryItem[] = [
			{
				label: "Instructions",
				description: "Coding styles and best practices",
				detail: "Guidelines for generating code that follows specific patterns",
				category: "instructions",
				iconPath: new vscode.ThemeIcon("list-ordered"),
			},
			{
				label: "Prompts",
				description: "Task-specific templates",
				detail:
					"Pre-defined prompts for common tasks like testing, documentation, etc.",
				category: "prompts",
				iconPath: new vscode.ThemeIcon("chevron-right"),
			},
			{
				label: "Agents",
				description: "AI assistant behavior profiles",
				detail: "Configure how Copilot behaves for different activities",
				category: "agents",
				iconPath: new vscode.ThemeIcon("color-mode"),
			},
			{
				label: "Collections",
				description: "Curated bundles of related items",
				detail:
					"Install multiple prompts, instructions, and agents together as a collection",
				category: "collections",
				iconPath: new vscode.ThemeIcon("library"),
			},
		];

		return this.showPickerWithMemory(categories, {
			title: "DHPAI",
			placeholder: "Select DHPAI category",
			preferenceKey: "last-category",
			matchFn: (item, lastChoice) => item.category === lastChoice,
			saveFn: (item) => item.category,
		});
	}

	/**
	 * Get items by category
	 */
	private getItemsByCategory(index: IndexData, category: string): IndexItem[] {
		switch (category) {
			case "instructions":
				return index.instructions || [];
			case "prompts":
				return index.prompts || [];
			case "agents":
				return index.agents || [];
			case "collections":
				return index.collections || [];
			default:
				return [];
		}
	}

	/**
	 * Show item picker
	 */
	async showItemPicker(
		index: IndexData,
		category: string,
	): Promise<ItemPickerItem | undefined> {
		const items = this.getItemsByCategory(index, category);

		const pickerItems: ItemPickerItem[] = items.map((item) => ({
			label: item.title,
			description: item.filename,
			detail: item.description,
			item: item,
			iconPath: new vscode.ThemeIcon("copilot"),
		}));

		const preferenceKey = `last-item-${category}`;

		return this.showPickerWithMemory(pickerItems, {
			title: "DHPAI",
			placeholder: `Select a ${category} item`,
			preferenceKey,
			matchFn: (item, lastChoice) =>
				item.item.filename === (lastChoice as { filename?: string })?.filename,
			saveFn: (item) => item.item,
		});
	}

	/**
	 * Show action picker
	 */
	async showActionPicker(
		item: ItemPickerItem,
		category: string,
	): Promise<ActionItem | undefined> {
		const isCollection = category === "collections";

		const actions: ActionItem[] = isCollection
			? [
					{
						label: "View Collection",
						description: "Open YAML in untitled editor",
						detail: "Preview the collection YAML file",
						action: "view",
						iconPath: new vscode.ThemeIcon("preview"),
					},
					{
						label: "Install All Items Globally",
						description: "Install all items to user profile",
						detail: "Install all items in this collection globally",
						action: "install-all-global",
						iconPath: new vscode.ThemeIcon("cloud-download"),
					},
					{
						label: "Install All Items in Workspace",
						description: "Install all items to workspace",
						detail: "Install all items in this collection to workspace",
						action: "install-all-workspace",
						iconPath: new vscode.ThemeIcon("desktop-download"),
					},
				]
			: [
					{
						label: "View Content",
						description: "Open in untitled editor",
						detail: "Preview the markdown content in an editor",
						action: "view",
						iconPath: new vscode.ThemeIcon("preview"),
					},
					{
						label: "Install Globally",
						description: "Save to user profile",
						detail: "Available across all your workspaces",
						action: "global",
						iconPath: new vscode.ThemeIcon("globe"),
					},
					{
						label: "Install in Workspace",
						description: "Save to this workspace only",
						detail: "Only available in this project",
						action: "workspace",
						iconPath: new vscode.ThemeIcon("github-project"),
					},
				];

		return this.showPickerWithMemory(actions, {
			title: "DHPAI",
			placeholder: `Action for ${item.item.title}`,
			preferenceKey: "last-action",
			matchFn: (actionItem, lastChoice) => actionItem.action === lastChoice,
			saveFn: (actionItem) => actionItem.action,
		});
	}
}
