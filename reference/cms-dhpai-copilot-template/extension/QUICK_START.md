# Quick Start Guide

Get up and running with Awesome Copilot (GitHub Enterprise) in 5 minutes!

## Step 1: Installation

### Install from VSIX

1. Download the `.vsix` file
2. In VS Code: `Ctrl+Shift+P` → "Extensions: Install from VSIX..."
3. Select the downloaded file
4. Reload VS Code

## Step 2: First Use & Login

1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
2. Type: `Awesome Copilot: Explore`
3. Choose your login method:

### 🌐 Login with Browser (Best UX)

_Requires OAuth setup - see [OAUTH_SETUP.md](OAUTH_SETUP.md)_

- Opens browser
- Login to GitHub Enterprise
- Automatically returns to VS Code
- Done! 🎉

### 👤 Login with Username & Password (Easiest)

_No setup required!_

- Enter your GitHub Enterprise username
- Enter your password
- Done! 🎉

### 🔑 Login with Personal Access Token (Traditional)

_No setup required!_

1. First, get a token: https://hagithub.home/settings/tokens
2. Create token with `repo` scope
3. Copy the token
4. Paste when prompted
5. Done! 🎉

**Recommendation**: Use Username & Password for quick start, or OAuth for best experience

## Step 3: Browse and Install

The extension shows you 4 categories:

### 📋 Instructions

Guidelines and best practices for code generation

- Example: Java coding standards, React patterns

### ⚡ Prompts

Task-specific templates

- Example: "Generate unit tests", "Write documentation"

### 🎨 Agents

Configure Copilot's behavior

- Example: "Senior Java Developer", "Frontend Expert"

### 📚 Collections

Install multiple items at once

- Example: "Complete Java Setup", "React Testing Bundle"

## Using the Extension

### View an Item

1. Select a category
2. Pick an item
3. Choose "View Content"
4. Preview opens in a new editor

### Install Globally

Installs to your user profile - available in ALL workspaces

1. Select item
2. Choose "Install Globally"
3. File opens automatically

**Where it goes:**

- Instructions: `~/.vscode/instructions/`
- Prompts/Agents: `{VSCode User}/prompts/`

### Install to Workspace

Installs to current project only

1. Select item
2. Choose "Install in Workspace"
3. For instructions, pick:
   - `.github/instructions/` (separate files)
   - `.github/copilot-instructions.md` (single file)

**Where it goes:**

- Instructions: `.github/instructions/` or `.github/copilot-instructions.md`
- Prompts: `.github/prompts/`
- Agents: `.github/agents/`

### Install a Collection

Bundle of related items

1. Select "Collections" category
2. Pick a collection
3. Choose:
   - "Install All Items Globally"
   - "Install All Items in Workspace"
4. Wait for progress notification
5. All items installed! ✅

## Tips & Tricks

### 💡 Smart Memory

The extension remembers your last selections in each category for faster navigation!

### 🔄 Append to copilot-instructions.md

When installing instructions to `copilot-instructions.md`:

- First time: Creates the file
- Already exists: Choose "Append" or "Replace"

### 🔐 Secure Storage

Your token is stored securely using VS Code's Secret Storage API

### 🚪 Logout

To clear your token:
`Ctrl+Shift+P` → `Awesome Copilot: Logout`

## Common Use Cases

### Scenario 1: Setting Up a New Project

1. Install "Collections" → "Project Setup Bundle" → Workspace
2. All necessary prompts, instructions, and agents installed
3. Start coding with consistent patterns!

### Scenario 2: Personal Preferences Across Projects

1. Install your favorite prompts → Globally
2. Install your preferred coding instructions → Globally
3. Available in every workspace automatically

### Scenario 3: Team Standards

1. Team lead installs "Team Standards" collection → Workspace
2. Commit `.github/` folder to repository
3. All team members get the same setup

## Configuration (Optional)

If you need to change settings:

1. `Ctrl+,` → Search "Awesome Copilot"
2. Modify:
   - **Base URL**: Your GitHub Enterprise instance
   - **Repository**: Source repository path
   - **Branch**: Branch to fetch from

Default works for most users! ✅

## Troubleshooting

### Can't authenticate?

- **OAuth**: Check Client ID/Secret are configured correctly
- **Basic Auth**: Verify username and password are correct
- **PAT**: Verify token has `repo` scope and hasn't expired
- Ensure you can access hagithub.home in browser
- Try a different authentication method

### Can't see items?

- Check network connection
- Verify repository access
- Try logout and login again

### Items not working after install?

- Restart VS Code (for global installs)
- Check file was created in the correct location
- For workspace installs, check `.github/` folder exists

## Next Steps

- **Explore** different categories
- **Install** items you need
- **Create** your own items (see repository documentation)
- **Share** collections with your team

## Need Help?

- Check [README.md](README.md) for detailed documentation
- See [INSTALL.md](INSTALL.md) for installation options
- Visit: https://hagithub.home/CMS/cms-dhpai-copilot-template/issues

---

**Happy coding with Awesome Copilot! 🚀**
