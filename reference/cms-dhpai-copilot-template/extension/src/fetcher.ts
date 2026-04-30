/**
 * Service for fetching content from GitHub Enterprise
 */

import * as vscode from "vscode";
import { GitHubEnterpriseAuth } from "./auth";
import { IndexData } from "./types";

export class ContentFetcher {
	private auth: GitHubEnterpriseAuth;
	private baseUrl: string;
	private repository: string;
	private branch: string;

	constructor(auth: GitHubEnterpriseAuth) {
		this.auth = auth;
		this.baseUrl = this.getBaseUrl();
		this.repository = this.getRepository();
		this.branch = this.getBranch();
	}

	private getBaseUrl(): string {
		const config = vscode.workspace.getConfiguration("dhpai");
		return config.get<string>("baseUrl", "hagithub.home");
	}

	private getRepository(): string {
		const config = vscode.workspace.getConfiguration("dhpai");
		return config.get<string>("repository", "CMS/cms-dhpai-copilot-template");
	}

	private getBranch(): string {
		const config = vscode.workspace.getConfiguration("dhpai");
		return config.get<string>("branch", "main");
	}

	private getIndexUrl(): string {
		return `https://${this.baseUrl}/raw/${this.repository}/${this.branch}/index.json`;
	}

	private getContentUrl(path: string): string {
		// Remove leading slash if present
		const cleanPath = path.startsWith("/") ? path.substring(1) : path;
		return `https://${this.baseUrl}/raw/${this.repository}/${this.branch}/${cleanPath}`;
	}

	/**
	 * Fetch the index.json file
	 */
	async fetchIndex(): Promise<IndexData> {
		const headers = await this.auth.getAuthHeaders();
		const url = this.getIndexUrl();

		try {
			const response = await fetch(url, { headers });

			if (!response.ok) {
				throw new Error(
					`Failed to fetch index: ${response.status} ${response.statusText}`,
				);
			}

			const data = (await response.json()) as IndexData;
			return data;
		} catch (error) {
			throw new Error(
				`Failed to fetch index from ${url}: ${error instanceof Error ? error.message : String(error)}`,
			);
		}
	}

	/**
	 * Fetch content from a specific path
	 */
	async fetchContent(path: string): Promise<string> {
		const headers = await this.auth.getAuthHeaders();
		const url = this.getContentUrl(path);

		try {
			const response = await fetch(url, { headers });

			if (!response.ok) {
				throw new Error(
					`Failed to fetch content: ${response.status} ${response.statusText}`,
				);
			}

			const text = await response.text();
			return text;
		} catch (error) {
			throw new Error(
				`Failed to fetch content from ${url}: ${error instanceof Error ? error.message : String(error)}`,
			);
		}
	}
}
