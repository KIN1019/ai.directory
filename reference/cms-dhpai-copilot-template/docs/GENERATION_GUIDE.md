# 📖 Documentation Generation Guide

This guide explains how to generate and maintain the documentation for your GitHub Copilot resources.

## 🎯 Overview

The documentation generation script (`scripts/generate-docs.js`) automatically creates formatted markdown files with installation links for all your:

- 📋 **Instructions** (`.instructions.md`)
- 🎯 **Prompts** (`.prompt.md`)
- 🤖 **Agents** (`.agent.md`)
- 📦 **Collections** (`.collection.yml`)

## 🚀 Quick Start

### Generate Documentation

```bash
npm run generate:docs
```

This will:

1. Scan all resource directories
2. Extract metadata from each file
3. Generate formatted markdown files in the `docs/` directory
4. Create installation links for VS Code and VS Code Insiders

## ⚙️ Configuration

Before using the script for your own repository, update the configuration in `scripts/generate-docs.js`:

### 1. VS Code Extension Details

```javascript
const CONFIG = {
	publisher: "your-publisher-name", // Your VS Code publisher name
	extensionName: "awesome-copilot-ghe", // Your extension name
	// ...
};
```

Replace:

- `your-publisher-name` with your VS Code publisher name (from `extension/package.json`)
- The extension name should match your extension's name

**This is critical** as it determines the `vscode://` protocol URLs that are generated.

### 2. Repository URL (Optional)

Only needed if you reference raw file URLs elsewhere:

```javascript
const CONFIG = {
	baseRepoUrl: "https://raw.githubusercontent.com/YOUR-ORG/YOUR-REPO/main",
	// ...
};
```

## 📝 File Requirements

### Required Metadata

For proper documentation generation, each file should include frontmatter with metadata:

#### Instructions, Prompts, Chat Modes, Agents

```yaml
---
title: Your Resource Title
description: A clear description of what this resource does
---
```

**Fallback Behavior:**

- If `title` is missing, the script will extract it from the first `#` heading
- If still not found, it will use the filename
- If `description` is missing, it will be left blank

#### Collections

```yaml
id: collection-id
name: Collection Name
description: "Description of the collection"
tags: [tag1, tag2, tag3]
items:
  - path: instructions/example.instructions.md
    kind: instruction
```

### File Naming Conventions

The script uses file extensions to identify resource types:

| Resource Type | Extension          | Example                               |
| ------------- | ------------------ | ------------------------------------- |
| Instructions  | `.instructions.md` | `java-best-practices.instructions.md` |
| Prompts       | `.prompt.md`       | `code-review.prompt.md`               |
| Agents        | `.agent.md`        | `expert-reviewer.agent.md`            |
| Collections   | `.collection.yml`  | `java-full-stack.collection.yml`      |

**Note:** Files without the proper extension will be ignored.

## 📂 Directory Structure

```
your-repo/
├── docs/
│   ├── README.md                    # Overview
│   ├── README.instructions.md       # Generated
│   ├── README.prompts.md           # Generated
│   ├── README.agents.md            # Generated
│   └── README.collections.md       # Generated
├── instructions/
│   └── *.instructions.md
├── prompts/
│   └── *.prompt.md
├── agents/
│   └── *.agent.md
├── collections/
│   └── *.collection.yml
└── scripts/
    └── generate-docs.js
```

## 🔧 Customization

### Adding New Resource Types

To add a new resource type, update the `CONFIG.directories` object in `generate-docs.js`:

```javascript
const CONFIG = {
	directories: {
		// ... existing types
		newtype: {
			dir: "newtype",
			extension: ".newtype.md",
			outputFile: "docs/README.newtype.md",
			title: "🎨 New Type",
			emoji: "🎨",
			description: "Description of this resource type",
			uriScheme: "chat-newtype",
		},
	},
};
```

### Understanding the Generated Links

The script generates `vscode://` protocol links in this format:

```
vscode://publisher.extension-name/install?type=TYPE&link=PATH&target=TARGET
```

**Parameters:**

- `publisher`: Your VS Code publisher name (from CONFIG)
- `extension-name`: Your extension name (from CONFIG)
- `type`: instruction, prompt, chatmode, collection, or agent
- `link`: Relative path to the file
- `target`: Installation target (default: `ask` - prompts user)

**Example:**

```
vscode://dhpai.dhpai/install?type=instruction&link=instructions/java.instructions.md&target=ask
```

When clicked, this link will:

1. Open VS Code (if not already open)
2. Activate your extension
3. Prompt the user to choose where to install (global or workspace)
4. Download and install the resource

### Customizing Markdown Output

To change the markdown format, edit the `generateMarkdownForType()` function in `generate-docs.js`.

The template includes:

- Title with emoji
- Description
- Usage instructions
- Table with install buttons
- Generation timestamp

## 🎨 Badge Customization

The install buttons use shields.io badges. To customize:

```javascript
// VS Code badge
[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)]

// VS Code Insiders badge
[![Install in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install-24bfa5?style=flat-square&logo=visualstudiocode&logoColor=white)]
```

Available customizations:

- `style`: `flat`, `flat-square`, `plastic`, `for-the-badge`
- Colors: Hex codes (e.g., `0098FF`)
- Logo: From [Simple Icons](https://simpleicons.org/)

## 🔍 Troubleshooting

### No files found

**Problem:** "No files found in [directory]"

**Solutions:**

1. Check that files have the correct extension
2. Verify the directory exists
3. Ensure files don't match skip patterns (e.g., `TEMPLATE`)

### Missing metadata

**Problem:** Files appear without titles or descriptions

**Solutions:**

1. Add frontmatter to the file:
   ```yaml
   ---
   title: Your Title
   description: Your description
   ---
   ```
2. Add a `#` heading as the first content line
3. The filename will be used as a last resort

### Wrong install links

**Problem:** Install links point to the wrong repository

**Solution:** Update `CONFIG.baseRepoUrl` in `scripts/generate-docs.js`

### Template files included

**Problem:** Template files appear in documentation

**Solution:** The script automatically skips files with "TEMPLATE" in the name. Ensure template files follow this convention.

## 🔄 Workflow Integration

### CI/CD Integration

Add to your GitHub Actions workflow:

```yaml
name: Generate Documentation

on:
  push:
    paths:
      - "instructions/**"
      - "prompts/**"
      - "chatmodes/**"
      - "collections/**"
      - "agents/**"

jobs:
  generate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "18"

      - name: Install dependencies
        run: npm install

      - name: Generate documentation
        run: npm run generate:docs

      - name: Commit changes
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add docs/
          git commit -m "docs: regenerate documentation" || echo "No changes"
          git push
```

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
npm run generate:docs
git add docs/
```

## 📋 Best Practices

1. **Always regenerate after changes**: Run `npm run generate:docs` after adding or modifying resources

2. **Keep frontmatter updated**: Ensure `title` and `description` are accurate and helpful

3. **Use semantic titles**: Make titles descriptive and searchable

4. **Write clear descriptions**: Explain what the resource does and when to use it

5. **Test install links**: Verify that generated links work correctly

6. **Version control**: Commit both source files and generated documentation together

7. **Review generated output**: Check the generated markdown before committing

## 🤝 Contributing

When contributing new resources:

1. Create your file in the appropriate directory
2. Add proper frontmatter with `title` and `description`
3. Follow the naming convention (`.instructions.md`, `.prompt.md`, etc.)
4. Run `npm run generate:docs`
5. Verify the generated documentation
6. Submit a PR with both the resource and updated documentation

## 📚 Additional Resources

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [VS Code Extension API](https://code.visualstudio.com/api)
- [YAML Specification](https://yaml.org/spec/)
- [Markdown Guide](https://www.markdownguide.org/)

---

**Last Updated:** 2025-11-11
