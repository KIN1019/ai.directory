---
title: CMS DHPAI Copilot Instruction
description: This is a template starter for configuring AI coding agents in VS Code workspaces. The project provides structured prompt templates and configuration patterns for AI-assisted development workflows.. Go to [https://hagithub.home/CMS/cms-dhpai-copilot-playbook-doc] for more details.
tags: [dhpai, vscode, copilot]
---

# VS Code Copilot Instructions

## Project Overview

This is a template starter for configuring AI coding agents in VS Code workspaces. The project provides structured prompt templates and configuration patterns for AI-assisted development workflows.

## Key Architecture

### Prompt Management System

- **`.github/prompts/`** - Centralized prompt templates with YAML frontmatter configuration
- Each prompt includes `mode`, `model`, `tools`, and `description` metadata
- Prompts follow a structured format with repo info, steps, and requirements sections

### Agent Configuration Pattern

```yaml
---
mode: agent
model: Claude Sonnet 4
tools: ["hagithub"]
description: Agent purpose and scope
---
```

## Project-Specific Conventions

### Prompt Template Structure

1. **YAML Frontmatter** - Define agent capabilities and model preferences
2. **Repo Info Section** - Context about target repository (owner, language, framework, CI/CD)
3. **Steps Section** - Numbered workflow instructions for agent execution
4. **Requirements Section** - Constraints and behavioral guidelines

### File Naming Patterns

- Prompt files: `{purpose}.prompt.md` (e.g., `pr-review.prompt.md`)
- Backup configurations: `{filename}.bak` for versioning
- Agent instructions: `copilot-instructions.md` in `.github/` directory

## Critical Workflows

### Prompt Development

- Create prompts in `.github/prompts/` with structured YAML headers
- Include specific repo context (language, framework, tools)
- Define clear step-by-step agent workflows
- Specify tool requirements and constraints

### Configuration Management

- Use `.bak` files for instruction versioning
- Maintain separation between generic templates and project-specific instructions
- Reference specific tools (e.g., "hagithub" for GitHub integration)

## Integration Points

- **GitHub Integration** - Prompts expect GitHub API access via specialized tools
- **VS Code Extensions** - Designed for Copilot and similar AI coding assistants
- **Multi-Agent Workflows** - Support for different AI models and capabilities per task

## Development Guidelines

- Always include progress indicators in agent workflows ("must show which steps are in progress")
- Provide clickable links to source files in agent outputs
- Maintain clear boundaries between analysis and modification tasks
- Structure prompts for specific repository contexts rather than generic use