/**
 * GitHub Enterprise authentication service
 * Supports multiple authentication methods:
 * 1. OAuth (web-based login) - Best UX
 * 2. Basic Auth (username/password)
 * 3. Personal Access Token (PAT)
 */

import * as vscode from "vscode";
import * as crypto from "crypto";

const CREDENTIALS_KEY = "dhpai.credentials";
const AUTH_TYPE_KEY = "dhpai.authType";

type AuthType = "oauth" | "basic" | "pat";

interface BasicAuthCredentials {
	username: string;
	password: string;
}

export class GitHubEnterpriseAuth {
	private context: vscode.ExtensionContext;
	private baseUrl: string;
	private pendingStates = new Map<string, (token: string) => void>();

	constructor(context: vscode.ExtensionContext) {
		this.context = context;
		this.baseUrl = this.getBaseUrl();
	}

	private getBaseUrl(): string {
		const config = vscode.workspace.getConfiguration("dhpai");
		return config.get<string>("baseUrl", "hagithub.home");
	}

	private getClientId(): string {
		const config = vscode.workspace.getConfiguration("dhpai");
		return config.get<string>("oauthClientId", "");
	}

	/**
	 * Handle OAuth callback (called by URI handler)
	 */
	async handleOAuthCallback(code: string, state: string): Promise<void> {
		const resolver = this.pendingStates.get(state);
		if (resolver) {
			this.pendingStates.delete(state);

			try {
				const token = await this.exchangeCodeForToken(code);
				resolver(token);
			} catch (error) {
				vscode.window.showErrorMessage(
					`Failed to complete authentication: ${error instanceof Error ? error.message : String(error)}`,
				);
			}
		}
	}

	/**
	 * Exchange OAuth code for access token
	 */
	private async exchangeCodeForToken(code: string): Promise<string> {
		const clientId = this.getClientId();
		const config = vscode.workspace.getConfiguration("dhpai");
		const clientSecret = config.get<string>("oauthClientSecret", "");

		const response = await fetch(
			`https://${this.baseUrl}/login/oauth/access_token`,
			{
				method: "POST",
				headers: {
					"Content-Type": "application/json",
					Accept: "application/json",
				},
				body: JSON.stringify({
					client_id: clientId,
					client_secret: clientSecret,
					code: code,
				}),
			},
		);

		if (!response.ok) {
			throw new Error(`Failed to exchange code for token: ${response.status}`);
		}

		const data = (await response.json()) as {
			access_token?: string;
			error?: string;
		};

		if (data.error || !data.access_token) {
			throw new Error(data.error || "No access token received");
		}

		return data.access_token;
	}

	/**
	 * Get stored token
	 */
	async getToken(): Promise<string | undefined> {
		return await this.context.secrets.get(CREDENTIALS_KEY);
	}

	/**
	 * Store token securely
	 */
	async setToken(token: string, authType: AuthType = "pat"): Promise<void> {
		await this.context.secrets.store(CREDENTIALS_KEY, token);
		await this.context.globalState.update(AUTH_TYPE_KEY, authType);
	}

	/**
	 * Clear stored token
	 */
	async clearToken(): Promise<void> {
		await this.context.secrets.delete(CREDENTIALS_KEY);
		await this.context.globalState.update(AUTH_TYPE_KEY, undefined);
	}

	/**
	 * Check if user is authenticated
	 */
	async isAuthenticated(): Promise<boolean> {
		const token = await this.getToken();
		return !!token;
	}

	/**
	 * OAuth web-based login
	 */
	async loginWithOAuth(): Promise<boolean> {
		const clientId = this.getClientId();

		if (!clientId) {
			vscode.window.showErrorMessage(
				'OAuth Client ID not configured. Please set "dhpai.oauthClientId" in settings or use PAT login.',
			);
			return false;
		}

		// Generate random state for CSRF protection
		const state = crypto.randomBytes(16).toString("hex");
		const callbackUri = await vscode.env.asExternalUri(
			vscode.Uri.parse(`${vscode.env.uriScheme}://dhpai.dhpai/auth-callback`),
		);

		// Construct authorization URL
		const authUrl =
			`https://${this.baseUrl}/login/oauth/authorize?` +
			`client_id=${encodeURIComponent(clientId)}&` +
			`redirect_uri=${encodeURIComponent(callbackUri.toString())}&` +
			`state=${state}&` +
			`scope=repo`;

		// Wait for the OAuth callback
		return new Promise<boolean>((resolve) => {
			this.pendingStates.set(state, async (token: string) => {
				try {
					// Validate token
					const isValid = await this.validateToken(token);
					if (isValid) {
						await this.setToken(token, "oauth");
						vscode.window.showInformationMessage(
							"Successfully authenticated with GitHub",
						);
						resolve(true);
					} else {
						vscode.window.showErrorMessage(
							"Received invalid token from OAuth flow",
						);
						resolve(false);
					}
				} catch (error) {
					vscode.window.showErrorMessage(
						`Failed to validate token: ${error instanceof Error ? error.message : String(error)}`,
					);
					resolve(false);
				}
			});

			// Open browser for authentication
			vscode.env.openExternal(vscode.Uri.parse(authUrl));

			// Timeout after 5 minutes
			setTimeout(
				() => {
					if (this.pendingStates.has(state)) {
						this.pendingStates.delete(state);
						vscode.window.showWarningMessage("Authentication timed out");
						resolve(false);
					}
				},
				5 * 60 * 1000,
			);
		});
	}

	/**
	 * Basic auth login (username/password)
	 */
	async loginWithBasicAuth(): Promise<boolean> {
		const username = await vscode.window.showInputBox({
			prompt: `Enter your GitHub username for ${this.baseUrl}`,
			ignoreFocusOut: true,
			placeHolder: "username",
		});

		if (!username) {
			return false;
		}

		const password = await vscode.window.showInputBox({
			prompt: "Enter your password",
			password: true,
			ignoreFocusOut: true,
			placeHolder: "password",
		});

		if (!password) {
			return false;
		}

		try {
			// Create Basic Auth token
			const basicToken = Buffer.from(`${username}:${password}`).toString(
				"base64",
			);

			// Test authentication
			const response = await fetch(`https://${this.baseUrl}/api/v3/user`, {
				headers: {
					Authorization: `Basic ${basicToken}`,
					Accept: "application/vnd.github.v3+json",
				},
			});

			if (!response.ok) {
				vscode.window.showErrorMessage(
					`Authentication failed: ${response.status} ${response.statusText}`,
				);
				return false;
			}

			// For Basic Auth, we store the base64 encoded credentials
			await this.setToken(basicToken, "basic");
			vscode.window.showInformationMessage(
				"Successfully authenticated with GitHub",
			);
			return true;
		} catch (error) {
			vscode.window.showErrorMessage(
				`Failed to authenticate: ${error instanceof Error ? error.message : String(error)}`,
			);
			return false;
		}
	}

	/**
	 * PAT token login
	 */
	async loginWithPAT(): Promise<boolean> {
		const token = await vscode.window.showInputBox({
			prompt: `Enter your GitHub Personal Access Token for ${this.baseUrl}`,
			password: true,
			ignoreFocusOut: true,
			placeHolder: "ghp_...",
			validateInput: (value: string) => {
				if (!value || value.trim().length === 0) {
					return "Token cannot be empty";
				}
				return null;
			},
		});

		if (!token) {
			return false;
		}

		// Validate token
		const isValid = await this.validateToken(token);
		if (isValid) {
			await this.setToken(token, "pat");
			vscode.window.showInformationMessage(
				"Successfully authenticated with GitHub",
			);
			return true;
		}

		return false;
	}

	/**
	 * Validate token by making API call
	 */
	private async validateToken(token: string): Promise<boolean> {
		try {
			const response = await fetch(`https://${this.baseUrl}/api/v3/user`, {
				headers: {
					Authorization: `token ${token}`,
					Accept: "application/vnd.github.v3+json",
				},
			});

			if (!response.ok) {
				vscode.window.showErrorMessage(
					`Authentication failed: ${response.status} ${response.statusText}`,
				);
				return false;
			}

			return true;
		} catch (error) {
			vscode.window.showErrorMessage(
				`Failed to authenticate: ${error instanceof Error ? error.message : String(error)}`,
			);
			return false;
		}
	}

	/**
	 * Main login method - presents options to user
	 */
	async login(): Promise<boolean> {
		const clientId = this.getClientId();

		const authOptions = [
			...(clientId
				? [
						{
							label: "$(globe) Login with Browser",
							description: "Recommended - Opens GitHub in your browser",
							method: "oauth" as const,
						},
					]
				: []),
			{
				label: "$(person) Login with Username & Password",
				description: "Basic authentication",
				method: "basic" as const,
			},
			{
				label: "$(key) Login with Personal Access Token",
				description: "Use a pre-generated PAT",
				method: "pat" as const,
			},
		];

		const choice = await vscode.window.showQuickPick(authOptions, {
			placeHolder: "Choose authentication method",
			ignoreFocusOut: true,
		});

		if (!choice) {
			return false;
		}

		switch (choice.method) {
			case "oauth":
				return await this.loginWithOAuth();
			case "basic":
				return await this.loginWithBasicAuth();
			case "pat":
				return await this.loginWithPAT();
			default:
				return false;
		}
	}

	/**
	 * Logout user
	 */
	async logout(): Promise<void> {
		await this.clearToken();
		vscode.window.showInformationMessage("Logged out from GitHub");
	}

	/**
	 * Get authentication headers for API calls
	 */
	async getAuthHeaders(): Promise<Record<string, string>> {
		const token = await this.getToken();
		const authType = this.context.globalState.get<AuthType>(
			AUTH_TYPE_KEY,
			"pat",
		);

		if (!token) {
			throw new Error("Not authenticated. Please login first.");
		}

		if (authType === "basic") {
			return {
				Authorization: `Basic ${token}`,
				Accept: "application/vnd.github.v3+json",
			};
		}

		// OAuth and PAT both use 'token' prefix
		return {
			Authorization: `token ${token}`,
			Accept: "application/vnd.github.v3+json",
		};
	}

	/**
	 * Ensure user is authenticated, prompt login if not
	 */
	async ensureAuthenticated(): Promise<boolean> {
		if (await this.isAuthenticated()) {
			return true;
		}

		const choice = await vscode.window.showInformationMessage(
			"You need to login to GitHub to use this feature",
			"Login",
			"Cancel",
		);

		if (choice === "Login") {
			return await this.login();
		}

		return false;
	}
}
