# 📚 Documentation

This directory contains automatically generated documentation for all the GitHub Copilot enhancements in this repository.

## 📖 Available Documentation

- **[📋 Instructions](README.instructions.md)** - Custom instructions for specific technologies and coding practices
- **[🎯 Prompts](README.prompts.md)** - Reusable prompt templates for common development tasks
- **[🤖 Agents](README.agents.md)** - Autonomous agents for complex workflows and specialized personas
- **[📦 Collections](README.collections.md)** - Curated bundles of related resources

## 🚀 Quick Start

### Installing Resources

Each documentation page includes install buttons that use the `vscode://` protocol:

1. Browse to the documentation page for the type of resource you want
2. Find the resource you need in the table
3. Click the **Install in VS Code** button
4. VS Code will open and prompt you to choose installation location (global or workspace)
5. The resource will be automatically installed to your chosen location

### Using Resources

#### Instructions

- Automatically apply to Copilot when placed in `.github/copilot-instructions.md`
- Can be scoped to specific files using the `applyTo` frontmatter field

#### Prompts

- Invoke in Copilot Chat using `#` followed by the prompt name
- Can be customized for your specific needs

#### Agents

- Activate to change Copilot's behavior and persona
- Agents provide autonomous capabilities for complex workflows
- Switch between agents for different types of tasks

#### Collections

- Install entire collections to quickly configure Copilot
- Collections bundle related instructions, prompts, and agents

## 🔄 Regenerating Documentation

The documentation is automatically generated from the source files in the repository using the generation script.

### To regenerate the documentation:

```bash
npm run generate:docs
```

### Configuration

Before generating documentation for your own repository, update the configuration in `scripts/generate-docs.js`:

```javascript
const CONFIG = {
	baseRepoUrl: "https://raw.githubusercontent.com/YOUR-ORG/YOUR-REPO/main",
	baseInstallUrl: "https://aka.ms/awesome-copilot/install",
	// ... other configuration
};
```

Replace `YOUR-ORG/YOUR-REPO` with your actual GitHub organization and repository name.

## 📝 Documentation Format

Each documentation file includes:

- **Title and Description** - Overview of the resource type
- **Usage Instructions** - How to install and use the resources
- **Table of Resources** - Complete list with:
  - Title and link to source file
  - Install buttons for VS Code and VS Code Insiders
  - Description of what the resource does

## 🤝 Contributing

When adding new resources to this repository:

1. Add your files to the appropriate directory (`instructions/`, `prompts/`, `agents/`, `collections/`)
2. Ensure your files have proper frontmatter with `title` and `description` fields
3. Run `npm run generate:docs` to regenerate the documentation
4. Commit both your new files and the updated documentation

## 📅 Generation Timestamp

Each documentation file includes a generation timestamp at the bottom to help track when it was last updated.

---

**Note:** These documentation files are auto-generated. Do not edit them manually as your changes will be overwritten on the next generation.
