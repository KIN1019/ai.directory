# Contexts Directory

Library documentation contexts fetched dynamically from external sources. These appear in the `/contexts` section of the website.

## How It Works (DHPAI Context MCP Style)

This implementation follows the **DHPAI Context MCP** approach where:

1. **No local files stored** - Only minimal metadata in `_meta.yaml`
2. **Runtime fetching** - Documentation is fetched dynamically from external sources
3. **URL inference** - llms.txt URLs are automatically inferred from the source repository

## Format

Each library is a directory containing only a `_meta.yaml` file:

```yaml
name: Library Display Name
description: Brief description of the library
slug: library-slug-identifier
source: /owner/repo  # GitHub repo (llms.txt URL will be inferred)
lastUpdated: 2024-01-15
techStacks:
  - react
  - typescript
teams:
  - CMSCHASSIS
categories:
  - ui
```

### Required Fields

- `name`: Display name of the library
- `description`: Brief description shown on the card
- `slug`: Unique identifier used for routing
- `source`: GitHub repository path in `/owner/repo` format

### Optional Fields

- `lastUpdated`: Last update date in YYYY-MM-DD format
- `techStacks`: Array of technology tags (must match tags.yaml)
- `teams`: Array of team tags (must match tags.yaml)
- `categories`: Array of category tags (must match tags.yaml)

## URL Inference

The `llms.txt` URL is automatically inferred from the `source` field using the **DHP AI Code Context API**:

- Source: `/owner/repo` → `https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/owner/repo/llms.txt`
- Source: `https://github.com/owner/repo` → `https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/owner/repo/llms.txt`

This uses the internal HA service that serves indexed library documentation.

## Website Display

- **Card Title**: `name` field
- **Description**: `description` field  
- **Filters**: `techStacks`, `teams`, `categories` fields
- **Detail Page**: Fetches and displays llms.txt content with search functionality
- **Navigation**: Click card → Navigate to `/contexts/[slug]` → Search llms.txt content

## Tags

All tags (techStacks, teams, categories) must exist in `tags.yaml`:

```yaml
techStacks:
  - slug: new-tech
    name: Display Name
teams:
  - slug: new-team
    name: Team Name
categories:
  - slug: new-category
    name: Category Name
```

## Adding a New Library

1. Create a new directory: `resources/contexts/library-slug/`
2. Add `_meta.yaml` with required fields (especially `source`)
3. Ensure the source repository has an `llms.txt` file at root or `/main/llms.txt`
4. The library will automatically appear on `/contexts`

## Limitations

- **Requires DHP AI Code Context API**: Libraries must be indexed in the DHP AI service
- **Network dependency**: Content fetched at runtime requires HA network connectivity
- **Indexed repositories only**: Only works for repositories that have been indexed by the DHP AI service
- **HA internal**: Service is only accessible within Hospital Authority network

## Benefits

- ✅ **Always fresh**: Content is never stale, fetched directly from source
- ✅ **No duplication**: Single source of truth in the original repository  
- ✅ **Minimal maintenance**: Only metadata needs updating
- ✅ **Scalable**: Can easily add hundreds of libraries without bloating repo size
- ✅ **MCP-compatible**: Follows the same pattern as DHPAI Context MCP tools
