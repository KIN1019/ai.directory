# Installation Guide

## For End Users

### Method 1: Install from VSIX (Recommended)

1. Download the latest `.vsix` file from releases
2. Open VS Code
3. Go to Extensions view (`Ctrl+Shift+X` or `Cmd+Shift+X`)
4. Click the `...` menu at the top of Extensions view
5. Select "Install from VSIX..."
6. Select the downloaded `.vsix` file

### Method 2: Install from VS Code Marketplace

_(If published to your organization's private marketplace)_

1. Open Extensions view
2. Search for "Awesome Copilot (GitHub Enterprise)"
3. Click Install

## For Developers

### Prerequisites

- Node.js 20+ and npm
- VS Code 1.80.0 or higher
- Git

### Development Setup

1. Clone the repository:

```bash
git clone https://hagithub.home/CMS/cms-dhpai-copilot-template.git
cd cms-dhpai-copilot-template/extension
```

2. Install dependencies:

```bash
npm install
```

3. Compile TypeScript:

```bash
npm run compile
```

4. Open in VS Code:

```bash
code .
```

5. Press `F5` to launch Extension Development Host

### Building VSIX Package

1. Install vsce globally (if not already installed):

```bash
npm install -g @vscode/vsce
```

2. Build the package:

```bash
npm run vscode:prepublish
vsce package
```

3. The `.vsix` file will be created in the extension directory

### Testing

1. Run compile in watch mode:

```bash
npm run watch
```

2. Press `F5` in VS Code to start debugging
3. Test the commands in the Extension Development Host window

## First-Time Setup

### Creating a Personal Access Token

1. Navigate to: `https://hagithub.home/settings/tokens`
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Awesome Copilot Extension")
4. Select required scopes:
   - For private repositories: `repo` (full control)
   - For public repositories only: `public_repo`
5. Click "Generate token"
6. **Important**: Copy the token immediately (you won't be able to see it again)

### Using the Extension

1. Open VS Code
2. Open Command Palette: `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
3. Type: `Awesome Copilot: Explore and Install`
4. When prompted, paste your Personal Access Token
5. Start browsing and installing items!

## Configuration

You can customize the extension settings in VS Code:

1. Open Settings: `Ctrl+,` (Windows/Linux) or `Cmd+,` (Mac)
2. Search for "Awesome Copilot"
3. Configure:
   - **Base URL**: Your GitHub Enterprise instance (default: `hagithub.home`)
   - **Repository**: Repository path (default: `CMS/cms-dhpai-copilot-template`)
   - **Branch**: Branch name (default: `main`)

Or edit `settings.json` directly:

```json
{
	"awesome-copilot-ghe.baseUrl": "hagithub.home",
	"awesome-copilot-ghe.repository": "CMS/cms-dhpai-copilot-template",
	"awesome-copilot-ghe.branch": "main"
}
```

## Troubleshooting

### Authentication Issues

**Problem**: "Authentication failed" error

**Solutions**:

- Verify your token has the correct scopes
- Check if the token has expired
- Ensure you can access the GitHub Enterprise instance
- Try logging out and logging in again: `Awesome Copilot: Logout from GitHub Enterprise`

### Network Issues

**Problem**: "Failed to fetch index" or "Failed to fetch content"

**Solutions**:

- Check your internet connection
- Verify the GitHub Enterprise URL is correct
- Ensure you have access to the repository
- Check if there are any firewall or proxy issues

### Installation Issues

**Problem**: Items not appearing after installation

**Solutions**:

- Check the installation path in the success message
- For global installs, restart VS Code
- For workspace installs, ensure the `.github` folders were created
- Verify file permissions in the installation directory

## Uninstalling

1. Open Extensions view in VS Code
2. Find "Awesome Copilot (GitHub Enterprise)"
3. Click the gear icon
4. Select "Uninstall"
5. Reload VS Code when prompted

Your stored Personal Access Token will be automatically deleted.

## Support

For issues, questions, or feature requests:

- Check existing issues: https://hagithub.home/CMS/cms-dhpai-copilot-template/issues
- Create a new issue with detailed information about your problem
- Contact your GitHub Enterprise administrator for access-related issues
