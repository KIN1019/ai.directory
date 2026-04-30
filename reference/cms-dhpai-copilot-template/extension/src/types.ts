/**
 * Types for the DHPAI extension
 */

export interface IndexData {
	instructions: IndexItem[];
	prompts: IndexItem[];
	agents: IndexItem[];
	collections: IndexItem[];
}

export interface IndexItem {
	title: string;
	description: string;
	filename: string;
	link: string;
}

export interface CategoryItem {
	label: string;
	description: string;
	detail: string;
	category: string;
	iconPath: { id: string };
}

export interface ItemPickerItem {
	label: string;
	description: string;
	detail: string;
	item: IndexItem;
	iconPath: { id: string };
}

export interface ActionItem {
	label: string;
	description: string;
	detail: string;
	action: string;
	iconPath: { id: string };
}

export interface CollectionItem {
	path: string;
	kind?: string;
}

export interface InstallResult {
	success: boolean;
	path?: string;
	error?: string;
	mode?: string;
}

export interface Preferences {
	[key: string]: unknown;
}
