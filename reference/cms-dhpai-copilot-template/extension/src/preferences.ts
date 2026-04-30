/**
 * Preferences management for picker memory
 */

import * as vscode from "vscode";
import { Preferences } from "./types";

const PREFS_KEY = "dhpai-preferences";

export class PreferencesManager {
	private context: vscode.ExtensionContext;

	constructor(context: vscode.ExtensionContext) {
		this.context = context;
	}

	/**
	 * Get all preferences
	 */
	getPreferences(): Preferences {
		return this.context.globalState.get<Preferences>(PREFS_KEY, {});
	}

	/**
	 * Save a preference
	 */
	async savePreference(key: string, value: unknown): Promise<void> {
		const currentPrefs = this.getPreferences();
		currentPrefs[key] = value;
		await this.context.globalState.update(PREFS_KEY, currentPrefs);
	}

	/**
	 * Get a specific preference
	 */
	getPreference<T>(key: string, defaultValue: T): T {
		const prefs = this.getPreferences();
		return (prefs[key] as T) ?? defaultValue;
	}
}
