---
mode: "agent"
description: "Generate custom Copilot instructions from a codebase, extracting structure, conventions, and patterns."
---

# Generate Custom Instructions from Codebase

Create a set of precise, actionable custom instructions for GitHub Copilot by analyzing the structure, patterns, and conventions in the current codebase.

## Scope

- Focus on core modules
- Identify patterns common across multiple files
- Include naming conventions, error handling, and testing patterns

## Steps

1. Scan directory structure and key files
2. Extract architectural patterns and cross-cutting concerns
3. Summarize naming conventions and code style rules
4. Document error handling strategies and logging conventions
5. Capture testing patterns and coverage expectations
6. Produce concise instructions with short, imperative sentences

## Output

- A markdown file with sections for conventions, patterns, and examples
- Ready to add under `.github/copilot-instructions.md`
