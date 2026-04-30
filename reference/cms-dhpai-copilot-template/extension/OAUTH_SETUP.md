# OAuth Setup Guide for GitHub Enterprise

This guide explains how to set up OAuth authentication for the Awesome Copilot extension, which provides the best user experience with browser-based login.

## Overview

The extension supports **3 authentication methods**:

1. **🌐 OAuth (Web Login)** - Best UX, requires one-time setup
2. **👤 Basic Auth (Username/Password)** - Simple, no setup needed
3. **🔑 PAT (Personal Access Token)** - Manual token creation

## Quick Comparison

| Method         | Setup Required      | User Experience | Security        |
| -------------- | ------------------- | --------------- | --------------- |
| **OAuth**      | ✅ Admin setup once | ⭐⭐⭐⭐⭐ Best | ⭐⭐⭐⭐⭐ Best |
| **Basic Auth** | ❌ None             | ⭐⭐⭐ Good     | ⭐⭐⭐ Good\*   |
| **PAT**        | ❌ None             | ⭐⭐ Manual     | ⭐⭐⭐⭐ Good   |

\*Note: GitHub is deprecating Basic Auth in favor of tokens/OAuth

## Setting Up OAuth (Recommended)

### Step 1: Create OAuth App in GitHub Enterprise

1. Go to your GitHub Enterprise instance settings:

   ```
   https://hagithub.home/settings/developers
   ```

2. Click **"New OAuth App"** (or navigate via Organization settings for org-wide apps)

3. Fill in the application details:

   **Application Name:**

   ```
   Awesome Copilot Extension
   ```

   **Homepage URL:**

   ```
   https://hagithub.home/CMS/cms-dhpai-copilot-template
   ```

   **Application Description:**

   ```
   VS Code extension for browsing and installing Copilot instructions, prompts, and agents
   ```

   **Authorization Callback URL:**

   ```
   vscode://your-publisher-name.awesome-copilot-ghe/auth-callback
   ```

   ⚠️ **Important**: Replace `your-publisher-name` with your actual VS Code publisher name from `package.json`

4. Click **"Register application"**

5. You'll see:
   - **Client ID**: A string like `Iv1.abc123def456`
   - **Client Secret**: Click "Generate a new client secret"

6. **Copy both values** - you'll need them for configuration

### Step 2: Configure the Extension

#### Option A: User Settings (Recommended for testing)

1. Open VS Code Settings (`Ctrl+,` or `Cmd+,`)
2. Search for "Awesome Copilot"
3. Set:
   - **OAuth Client ID**: Paste your Client ID
   - **OAuth Client Secret**: Paste your Client Secret

Or edit `settings.json`:

```json
{
	"awesome-copilot-ghe.oauthClientId": "Iv1.abc123def456",
	"awesome-copilot-ghe.oauthClientSecret": "your_client_secret_here"
}
```

#### Option B: Workspace Settings (Recommended for teams)

Add to `.vscode/settings.json` in your repository:

```json
{
	"awesome-copilot-ghe.baseUrl": "hagithub.home",
	"awesome-copilot-ghe.repository": "CMS/cms-dhpai-copilot-template",
	"awesome-copilot-ghe.oauthClientId": "Iv1.abc123def456"
}
```

⚠️ **Security Note**: Do NOT commit Client Secret to repository. Users should add it to their User settings, or use environment variables.

#### Option C: Environment Variables (Production)

For production deployments, consider storing secrets as environment variables and loading them in the extension code.

### Step 3: Test OAuth Login

1. Run command: `Awesome Copilot: Explore and Install`
2. When prompted to login, you should see:
   - 🌐 **Login with Browser** (if OAuth is configured)
   - 👤 Login with Username & Password
   - 🔑 Login with Personal Access Token
3. Select "Login with Browser"
4. Your browser opens to GitHub Enterprise
5. Authorize the application
6. Automatically redirects back to VS Code
7. You're logged in! ✅

## Using Basic Auth (No Setup Required)

If you don't want to set up OAuth:

1. Run: `Awesome Copilot: Explore and Install`
2. Select: **Login with Username & Password**
3. Enter your GitHub Enterprise username
4. Enter your password
5. Done! ✅

**Pros:**

- No OAuth app creation needed
- Works immediately
- Simple for end users

**Cons:**

- Must enter credentials manually
- GitHub is deprecating Basic Auth
- Less secure than OAuth (credentials handled by extension)

## Using PAT (No Setup Required)

Traditional token-based auth:

1. Create a PAT at: `https://hagithub.home/settings/tokens`
2. Select scope: `repo` (for private repos)
3. Run: `Awesome Copilot: Explore and Install`
4. Select: **Login with Personal Access Token**
5. Paste your token
6. Done! ✅

**Pros:**

- Full control over token
- Can revoke anytime
- Familiar workflow

**Cons:**

- Manual token creation
- Must copy/paste token
- Less convenient than OAuth

## Recommendation for Organizations

### For Small Teams (< 10 users)

Use **Basic Auth** or **PAT** - simpler, no setup needed

### For Large Teams (10+ users)

Set up **OAuth** once:

1. Admin creates OAuth app
2. Share Client ID in workspace settings
3. Client Secret distributed securely (user settings or env vars)
4. All users get browser-based login ✨

## Switching Authentication Methods

Users can switch methods anytime:

1. Run: `Awesome Copilot: Logout`
2. Run: `Awesome Copilot: Explore and Install`
3. Choose a different authentication method

The extension stores which method was used and handles authentication accordingly.

## Security Best Practices

### For OAuth

- ✅ Store Client Secret in user settings, not workspace
- ✅ Use organization OAuth apps for better control
- ✅ Regularly rotate Client Secrets
- ✅ Limit OAuth app permissions to `repo` scope only

### For Basic Auth

- ✅ Use strong passwords
- ✅ Enable 2FA on GitHub Enterprise accounts
- ✅ Logout when done (credentials stored encrypted)

### For PAT

- ✅ Create tokens with minimal required scopes
- ✅ Set expiration dates on tokens
- ✅ Revoke old tokens regularly
- ✅ Don't share tokens

## Troubleshooting OAuth

### "OAuth Client ID not configured"

**Solution**: Add `awesome-copilot-ghe.oauthClientId` to settings

### "Failed to exchange code for token"

**Causes:**

- Client Secret is incorrect
- OAuth app callback URL doesn't match
- Network/firewall issues

**Solution:**

1. Verify Client Secret in settings
2. Check callback URL in OAuth app settings:
   ```
   vscode://your-publisher-name.awesome-copilot-ghe/auth-callback
   ```
3. Ensure `your-publisher-name` matches your publisher name

### "Authentication timed out"

**Cause**: Didn't complete auth in browser within 5 minutes

**Solution**: Try login again, complete the flow faster

### Browser doesn't redirect back to VS Code

**Causes:**

- VS Code protocol handler not registered
- Incorrect callback URL

**Solution:**

1. Check the OAuth app's callback URL is exactly:
   ```
   vscode://your-publisher-name.awesome-copilot-ghe/auth-callback
   ```
2. Try reinstalling the extension
3. Use Basic Auth or PAT as alternative

## For Extension Developers

### Customizing OAuth Flow

Edit `src/auth.ts`:

```typescript
// Change callback path
if (uri.path === "/auth-callback") {
	// Customize this
	// Handle callback
}

// Change scopes
const authUrl =
	`https://${this.baseUrl}/login/oauth/authorize?` + `scope=repo,user`; // Add more scopes if needed
```

### Using Organization OAuth Apps

For better control, create OAuth app under your organization:

1. Go to: `https://hagithub.home/organizations/YOUR_ORG/settings/applications`
2. Create OAuth app there
3. Benefits:
   - Centralized management
   - Better audit logs
   - Easier revocation

## Additional Resources

- [GitHub OAuth Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [VS Code Authentication API](https://code.visualstudio.com/api/references/vscode-api#authentication)
- [VS Code URI Handler](https://code.visualstudio.com/api/references/vscode-api#window.registerUriHandler)

## Summary

| If you want...        | Use...             | Setup Time        |
| --------------------- | ------------------ | ----------------- |
| Best UX for team      | OAuth              | 10 minutes (once) |
| Quick start, no setup | Basic Auth or PAT  | 0 minutes         |
| Maximum security      | OAuth with org app | 15 minutes (once) |
| Personal use          | PAT                | 2 minutes         |

Choose the method that best fits your needs!
