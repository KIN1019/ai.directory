# VS Code Copilot Settings Configuration

This file documents the VS Code workspace settings specifically configured for optimal GitHub Copilot and AI-assisted development experience.

## Overview

The `settings.json` file contains carefully curated settings to enhance your AI coding workflow with GitHub Copilot, including instruction files, model selection, and various AI features.

## Settings Categories

### 🌐 Network Configuration

```jsonc
"http.proxy": "http://<corp_id>:<proxy_pw>@proxy.ha.org.hk:8080",
"http.noProxy": [".server.ha.org.hk", ".home"]
```

- **Purpose**: Corporate proxy configuration for network access
- **Customization**: Replace with your organization's proxy settings or remove if not needed

### ✨ Editor Experience

```jsonc
"editor.inlineSuggest.edits.showCollapsed": true,
"terminal.integrated.fontSize": 13
```

- **`showCollapsed`**: Reduces visual clutter from Next Edit Suggestions
- **`fontSize`**: Optimizes terminal readability

## 🤖 AI Instructions Configuration

### Instruction Files Integration

```jsonc
"github.copilot.chat.codeGeneration.useInstructionFiles": true
```

- **Purpose**: Enables automatic loading of `.github/copilot-instructions.md`
- **Benefit**: Provides context-aware AI assistance based on your project patterns

### Commit Message Generation

```jsonc
"github.copilot.chat.commitMessageGeneration.instructions": [
    {
        "text": "Use conventional commit message format with emoji. Use present tense. Specify affected modules. e.g. feat(api)!: ✨send an email to the customer when a product is shipped"
    }
]
```

- **Format**: Conventional commits with emojis
- **Style**: Present tense, module specification
- **Example**: `feat(api)!: ✨send an email to the customer when a product is shipped`

### Code Review Instructions

```jsonc
"github.copilot.chat.reviewSelection.instructions": [
    {
        "file": ".github/instructions/review-selection.instructions.md"
    }
]
```

- **Purpose**: Custom code review guidelines
- **File**: References external instruction file for consistency

### Pull Request Description Generation

```jsonc
"github.copilot.chat.pullRequestDescriptionGeneration.instructions": [
    {
        "file": ".github/instructions/pr-desc-generation.instructions.md"
    }
]
```

- **Purpose**: Automated PR description generation
- **File**: Uses project-specific templates and patterns

## 🎯 Copilot Feature Configuration

### Model Selection

```jsonc
"github.copilot.selectedCompletionModel": ""
```

- **Default**: Uses GitHub's recommended model
- **Options**: Currently supports `gpt-4o-copilot` or empty string for default

### Next Edit Suggestions

```jsonc
"github.copilot.nextEditSuggestions.enabled": true,
"github.copilot.nextEditSuggestions.fixes": true
```

- **Enabled**: Activates proactive code suggestions
- **Fixes**: Includes automatic error fixing suggestions

### Auto-Fix and Thinking Tools

```jsonc
"github.copilot.chat.agent.autoFix": true,
"github.copilot.chat.agent.thinkingTool": true
```

- **AutoFix**: Automatically suggests fixes for detected issues
- **Thinking Tool**: Shows AI reasoning process for transparency

### Code Search Integration

```jsonc
"github.copilot.chat.codesearch.enabled": true,
"github.copilot.chat.scopeSelection": true
```

- **Code Search**: Enables `#codebase` prompt for repository-wide context
- **Scope Selection**: Improves context relevance for suggestions

### Test Generation

```jsonc
"github.copilot.chat.generateTests.codeLens": true
```

- **Purpose**: Adds "Generate Tests" CodeLens above functions/classes
- **Benefit**: Quick test generation workflow

### Project Templates

```jsonc
"github.copilot.chat.useProjectTemplates": true
```

- **Purpose**: Enables `/new` command for project bootstrapping
- **Benefit**: Rapid project setup with AI assistance

## 🛡️ Security & Language Configuration

### Language Enablement

```jsonc
"github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": true,
    "scminput": false
}
```

- **Global**: Enabled for most file types
- **Plaintext**: Disabled for security (may contain sensitive data)
- **Markdown**: Enabled for documentation generation
- **SCM Input**: Disabled for commit message fields

### Terminal Command Safety

```jsonc
"github.copilot.chat.agent.terminal.allowList": {
    "echo": true, "cd": true, "ls": true, "cat": true, "pwd": true,
    "Write-Host": true, "Set-Location": true, "Get-ChildItem": true,
    "Get-Content": true, "Get-Location": true
}
```

**Allowed Commands**: Safe, read-only operations for both Unix and PowerShell

```jsonc
"github.copilot.chat.agent.terminal.denyList": {
    "rm": true, "rmdir": true, "del": true, "kill": true,
    "curl": true, "wget": true, "eval": true, "chmod": true,
    "chown": true, "Remove-Item": true
}
```

**Blocked Commands**: Potentially destructive operations

## 🔍 Enhanced Search Features

### Semantic Search

```jsonc
"search.searchView.semanticSearchBehavior": "auto",
"search.searchView.keywordSuggestions": true
```

- **Semantic Search**: AI-powered code search by meaning, not just keywords
- **Keyword Suggestions**: Enhanced search term recommendations

### Settings Search

```jsonc
"workbench.settings.showAISearchToggle": true
```

- **Purpose**: AI-assisted VS Code settings discovery
- **Benefit**: Natural language queries for configuration changes

### Command Center Integration

```jsonc
"window.commandCenter": true,
"chat.commandCenter.enabled": true
```

- **Command Center**: Enhanced command palette experience
- **Chat Integration**: Direct AI chat access from command center

## 🔌 Model Context Protocol (MCP)

### MCP Configuration

```jsonc
"chat.mcp.enabled": true,
"chat.mcp.discovery.enabled": true
```

- **MCP Support**: Enables Model Context Protocol integrations
- **Auto-Discovery**: Automatically finds available MCP servers
- **Purpose**: Extends AI capabilities with external tools and data sources

## Customization Guide

### 1. Corporate Environment

- Update proxy settings for your organization
- Modify terminal command allowlists based on security policies
- Adjust network exclusions for internal domains

### 2. Personal Preferences

- Change terminal font size
- Modify commit message format
- Enable/disable specific Copilot features

### 3. Project-Specific Settings

- Update instruction file references
- Customize language enablement
- Adjust model selection preferences

### 4. Security Considerations

- Review terminal command permissions
- Validate proxy configurations
- Consider sensitive data handling in plaintext files

## Best Practices

### ✅ Recommended

- Keep instruction files updated with project patterns
- Use semantic search for better code discovery
- Enable thinking tools for AI transparency
- Maintain terminal command security lists

### ⚠️ Consider Carefully

- Proxy credentials in settings (use environment variables)
- Enabling Copilot for sensitive file types
- Terminal command permissions in team environments

### ❌ Avoid

- Storing passwords directly in settings
- Disabling all security restrictions
- Ignoring corporate security policies

## Troubleshooting

### Common Issues

1. **Copilot not working**: Check network proxy settings
2. **Instructions not loading**: Verify file paths in `.github/instructions/`
3. **Terminal commands blocked**: Review allowList/denyList configuration
4. **Semantic search unavailable**: Ensure latest VS Code version

### Support Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [GitHub Copilot Settings Reference](https://docs.github.com/en/copilot)
- [VS Code Settings Documentation](https://code.visualstudio.com/docs/getstarted/settings)

---

**Note**: This configuration is optimized for VS Code version 1.104.0 as of July 21, 2025. Settings may need updates for newer versions.
