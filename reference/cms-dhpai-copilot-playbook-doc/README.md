# VS Code Copilot Settings Template

A template repository for organizing AI coding instructions and VS Code workspace settings to maintain consistency across development projects.

> [!WARNING]
> **Verification Required:** All code generated should be thoroughly reviewed and tested before implementation. The AI may not account for specific project requirements or environments.

---

## Overview

This template provides a structured approach to:

- Organize AI coding instructions for different languages and frameworks
- Configure VS Code workspace settings for optimal AI-assisted development
- Maintain consistency across team projects and personal repositories

## Repository Structure

```bash
.github/
├── copilot-instructions.md          # Global AI coding guidelines
├── instructions/                    # Pattern-based instruction files
│   ├── spring-boot.instructions.md  # Java/Spring Boot specific guidance
│   └── pr-desc-generation.instructions.md  # PR description generation guidelines
└── prompts/                         # AI prompts and agent templates
    ├── code-review.prompt.md         # Code review agent prompt
    └── pr-review.prompt.md           # Pull request review agent prompt

.vscode/
├── settings.json                    # VS Code workspace configuration
└── mcp.json                         # Model Context Protocol configuration

docs/
└── vscode-settings.md               # Documentation for VS Code settings
```

## Quick Start

### 1. Use This Template

Copy this template, customize the instruction files for your project, and start building with consistent AI-assisted development patterns.

### 2. Customize Instructions

Edit the instruction files in `.github/instructions/` to match your project's needs:

- **Pattern-based instructions**: Use glob patterns to target specific file types
- **Framework-specific guidance**: Add instructions for your tech stack
- **Project conventions**: Document your team's coding standards

### 3. Configure VS Code Settings

Update `.vscode/settings.json` with your preferred workspace configuration.

## Instruction File Format

Instruction files use YAML frontmatter to specify which files they apply to:

```yaml
---
applyTo: "**/*.java"
---
# Your project-specific instructions here
```

### Common Patterns

| Pattern       | Description                       |
| ------------- | --------------------------------- |
| `**/*.java`   | All Java files                    |
| `**/*.ts`     | All TypeScript files              |
| `**/*.py`     | All Python files                  |
| `src/**/*.js` | JavaScript files in src directory |
| `**`          | All files                         |

## Features

### 🤖 AI-Powered Development

- Context-aware coding instructions for AI assistants
- Framework-specific guidance and best practices
- Automated code generation following project patterns

### 📁 Organized Structure

- Centralized instruction management
- Pattern-based file targeting
- Reusable across multiple projects

### ⚙️ VS Code Integration

- Optimized workspace settings
- Seamless AI assistant integration
- Team-consistent development environment

## MCP Servers

This repository is configured with the following Model Context Protocol (MCP) servers for enhanced AI capabilities:

### Available Servers

| Server           | Description                               | Capabilities                                                       |
| ---------------- | ----------------------------------------- | ------------------------------------------------------------------ |
| **HA Wiki**      | HA internal wiki/CMS server               | Content management, documentation access                           |
| **hagithub**     | GitHub Enterprise integration (ha.org.hk) | Repository analysis, PR management, issue tracking                 |
| **hagithubhome** | GitHub Enterprise integration (home)      | Repository analysis, PR management, issue tracking                 |
| **sonarqube**    | Code quality analysis                     | Static code analysis, security scanning, technical debt assessment |
| **mongodb**      | MongoDB database integration              | Database querying, collection analysis (read-only)                 |
| **grafana**      | Observability and monitoring              | Metrics visualization, dashboard access, alerting data             |

### Commented/Optional Servers

The following servers are available but currently disabled:

| Server                 | Description                    | Capabilities                            |
| ---------------------- | ------------------------------ | --------------------------------------- |
| **jfrog**              | Artifact repository management | Package management, dependency analysis |
| **context7**           | Enhanced context understanding | Advanced context processing             |
| **markitdown**         | Document conversion            | Markdown conversion utilities           |
| **sequentialthinking** | Reasoning enhancement          | Sequential thought processing           |

### Configuration

MCP servers are configured in `.vscode/mcp.json`. Each server provides specific tools and context to AI agents:

- **Repository Context**: Access to project files, structure, and metadata
- **GitHub Integration**: Direct API access for repository operations
- **Development Tools**: Code analysis and workflow automation
- **Database Access**: Read-only MongoDB integration for data analysis
- **Quality Gates**: SonarQube integration for code quality insights
- **Monitoring**: Grafana integration for observability data

> [!NOTE]
> MCP server availability depends on your local setup and authentication. Refer to `.vscode/mcp.json` for specific configuration details.

## Usage Examples

### Adding Framework Instructions

To create a new instruction file for your framework, follow these steps:

1. Navigate to the `.github/instructions/` directory in your project.
2. Create a new file named `react.instructions.md`.
3. Add the following content to the file:

   ```yaml
   ---
   applyTo: "**/*.tsx"
   ---
   # React Component Guidelines
   ```

### Customizing for Your Project

1. **Update patterns**: Modify `applyTo` values to match your project structure
2. **Add conventions**: Document your specific coding patterns and practices
3. **Include examples**: Reference actual files from your codebase
4. **Keep current**: Update instructions as your project evolves

## Best Practices

### Instruction Writing

- ✅ Focus on discoverable patterns in your codebase
- ✅ Include specific examples from actual files
- ✅ Keep instructions concise (20-50 lines)
- ❌ Avoid aspirational practices not yet implemented
- ❌ Don't duplicate generic coding advice

### File Organization

- Group related instructions by framework or language
- Use descriptive filenames (e.g., `spring-boot.instructions.md`)
- Maintain consistent YAML frontmatter format
- Reference external documentation when appropriate

## Contributing

1. Fork this repository
2. Create feature branch: `git checkout -b feature/new-instructions`
3. Add your instruction files following the established patterns
4. Update this README if adding new concepts
5. Submit a pull request

## Related Resources

- [VS Code Settings Documentation](https://code.visualstudio.com/docs/getstarted/settings)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [dhpai.home](https://dhpai.home/prompts) for external instruction references

## License

This template is provided as-is for use in your projects. Customize freely to match your team's needs.
