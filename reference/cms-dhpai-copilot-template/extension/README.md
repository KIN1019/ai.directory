# DHPAI

A VS Code extension for exploring and installing instructions, prompts, agents, and collections from GitHub.

## Features

- **AI-Powered Search**: Language Model Tool that enables AI assistants (like GitHub Copilot) to search and discover DHPAI resources automatically
- **GitHub Authentication**: Securely authenticate using Personal Access Tokens
- **Browse and Install**: Explore instructions, prompts, agents, and collections
- **Multiple Installation Options**:
  - Install globally (available across all workspaces)
  - Install to workspace (project-specific)
  - Install to `.github/copilot-instructions.md`
- **Collection Support**: Install multiple items at once from collections
- **Smart Memory**: Remembers your last selections for faster navigation

## Requirements

- VS Code 1.85.0 or higher (for Language Model Tool support)
- GitHub account on `hagithub.home`
- One of the following:
  - OAuth App credentials (best UX - browser-based login)
  - Username and password (simple, no setup)
  - Personal Access Token (traditional method)

## Getting Started

### Quick Start (No Setup Required)

1. Open Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
2. Run: `DHPAI: Explore and Install`
3. Choose your authentication method:
   - **🌐 Login with Browser** (if OAuth is configured)
   - **👤 Login with Username & Password** (recommended for quick start)
   - **🔑 Login with Personal Access Token**
4. Follow the prompts to authenticate
5. Browse and install items!

### Authentication Options

#### Option 1: OAuth (Browser Login) - Best UX ⭐

Provides seamless browser-based authentication. Requires one-time OAuth app setup.

**Setup:**

1. See OAUTH_SETUP.md for detailed instructions
2. Create OAuth app in GitHub
3. Configure Client ID and Secret in VS Code settings

**User Experience:**

- Click "Login with Browser"
- Authenticate in browser
- Automatically redirected back to VS Code
- Done! ✅

#### Option 2: Basic Auth (Username/Password) - Easiest

No setup required! Works immediately.

**Usage:**

1. Select "Login with Username & Password"
2. Enter your GitHub username
3. Enter your password
4. Done! ✅

#### Option 3: Personal Access Token (PAT) - Traditional

For users who prefer token-based authentication.

**Setup:**

1. Go to: `https://hagithub.home/settings/tokens`
2. Create new token with `repo` scope
3. Copy the token

**Usage:**

1. Select "Login with Personal Access Token"
2. Paste your token
3. Done! ✅

## Configuration

Configure the extension in VS Code settings:

```json
{
	"dhpai.baseUrl": "hagithub.home",
	"dhpai.repository": "CMS/cms-dhpai-copilot-template",
	"dhpai.branch": "main"
}
```

## Available Commands

- `DHPAI: Explore and Install` - Browse and install items
- `DHPAI: Logout` - Clear stored credentials
- `DHPAI: Clear Search Cache` - Clear the AI search tool cache for fresh results

## AI-Powered Search

The extension provides a **Language Model Tool** that allows AI assistants like GitHub Copilot to automatically search and discover DHPAI resources during conversations. No manual commands needed!

**Example Usage:**

- Ask Copilot: _"Find instructions about unit testing"_
- Ask Copilot: _"Show me all React prompts"_
- Ask Copilot: _"What collections are available?"_

The AI will automatically use the search tool to find relevant resources and provide detailed information about titles, descriptions, and categories.

For more details, see [LANGUAGE_MODEL_TOOL.md](./LANGUAGE_MODEL_TOOL.md)

## Categories

### Instructions

Guidelines for generating code that follows specific patterns and best practices.

### Prompts

Task-specific templates for common tasks like testing, documentation, etc.

### Agents

AI assistant behavior profiles to configure how Copilot behaves for different activities.

### Collections

Curated bundles of related items that can be installed together.

## Installation Locations

### Global Installation

- **Instructions**: `~/.vscode/instructions/`
- **Prompts/Agents**: `{VSCode User Dir}/prompts/`

### Workspace Installation

- **Instructions**: `.github/instructions/` or `.github/copilot-instructions.md`
- **Prompts**: `.github/prompts/`
- **Agents**: `.github/agents/`

## Security

- **Credentials Storage**: All authentication credentials (OAuth tokens, Basic Auth, PAT) are stored securely using VS Code's Secret Storage API
- **Encryption**: Credentials are encrypted at rest
- **No Logging**: Credentials are never logged or exposed in error messages
- **Limited Scope**: All authentication methods only access your configured GitHub instance
- **User Control**: Logout anytime to clear stored credentials

### Which Authentication Method is Most Secure?

1. **OAuth**: Most secure - credentials never handled by extension, managed by GitHub
2. **PAT**: Very secure - token with limited scopes, can be revoked anytime
3. **Basic Auth**: Secure - credentials encrypted, but GitHub is deprecating this method

## Development

### Building the Extension

```bash
cd extension
npm install
npm run compile
```

### Running in Development

1. Open the `extension` folder in VS Code
2. Press `F5` to launch the Extension Development Host
3. Test the extension in the new window

### Packaging

```bash
npm install -g @vscode/vsce
vsce package
```

## License

See LICENSE file in the repository.

## Support

For issues and questions, please contact your GitHub administrator or the repository maintainers.
