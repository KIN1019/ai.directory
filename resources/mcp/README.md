# MCP Directory

Model Context Protocol (MCP) server configurations for AI agents. These appear in the `/mcp` section of the website.

## Format

```yaml
name: Server Name
slug: server-slug
description: >-
  Brief description of what this MCP server provides
logo: /logo-image.png
setupDescription: |-
  - Setup instructions
  - Configuration steps
config:
  type: stdio|sse
  command: command-name # for stdio
  url: https://url # for sse
  args: # optional
    - arg1
  env: # optional
    ENV_VAR: ${input:variable_name}
tags:
  - tag1
  - tag2
tools:
  - name: tool_name
    description: What this tool does
```

**Website display:**

- `name` → Card title and individual page heading
- `description` → Card description text in listings
- `logo` → Server logo/icon displayed on cards
- `tags` → Filter categories and tag badges
- `tools` → Available tools list with descriptions
- `setupDescription` → Installation and setup instructions

**Tags:** Must exist in `tags.yaml` or error will be thrown. Add new tags there first:

```yaml
- slug: new-tag
  name: Display Name
```

**File naming:** Use kebab-case with numbers like `1-server-name.yaml`
