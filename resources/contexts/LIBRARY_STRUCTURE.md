# Library Context Structure (DHPAI Context MCP Pattern)

This directory contains library metadata that powers the Contexts page. The implementation follows the **DHPAI Context MCP** approach where documentation is fetched dynamically from external sources at runtime.

## Architecture Philosophy

Similar to how the DHPAI Context MCP uses:

- `code_context__resolve_library_id` - to find libraries
- `code_context__get_library_docs` - to fetch documentation dynamically

Our contexts page:

- Stores minimal metadata locally
- Infers llms.txt URLs from source repositories
- Fetches content at runtime
- Provides searchable documentation view

## Directory Structure

```
resources/contexts/
├── library-slug/
│   └── _meta.yaml          # Only metadata, no content files
├── tags.yaml               # Tag definitions for filtering
└── README.md               # This file
```

**No snippet folders, no local content** - everything is fetched dynamically!

## \_meta.yaml Format

```yaml
name: Library Display Name
description: Brief description of the library
slug: library-slug-identifier
source: /owner/repo # Required: GitHub repo path
lastUpdated: 2024-01-15 # Optional
techStacks:
  - react
  - typescript
teams:
  - CMSCHASSIS
categories:
  - ui
```

## Automatic URL Inference

The API automatically infers the llms.txt URL from the `source` field:

### Supported Patterns

1. **GitHub short path**: `/owner/repo`
   - Infers: `https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/owner/repo/llms.txt`

2. **Full GitHub URL**: `https://github.com/owner/repo`
   - Infers: `https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/owner/repo/llms.txt`

### Example

```yaml
source: /CMSCHASSIS/react-ui
```

Automatically fetches from:

```
https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/CMSCHASSIS/react-ui/llms.txt
```

## How It Works

### 1. Library List Page (`/contexts`)

- API reads all `_meta.yaml` files
- Infers llms.txt URLs from source fields
- Displays library cards with metadata
- Supports filtering by tech stack, team, category

### 2. Library Detail Page (`/contexts/[slug]`)

- Fetches library metadata
- Fetches llms.txt content from inferred URL
- Provides real-time search within documentation
- Shows filtered results with context

### 3. Runtime Fetching

```typescript
// API infers URL
GET /api/contexts/libraries
  → Returns libraries with inferred llmsTxtUrl

// Fetch content
GET /api/contexts/llms-txt?url={inferredUrl}
  → Proxies request to external source
  → Returns raw llms.txt content
```

## Adding a New Library

### Step 1: Create Directory

```bash
mkdir resources/contexts/my-new-library
```

### Step 2: Create \_meta.yaml

```yaml
name: My New Library
description: A great library for doing awesome things
slug: my-new-library
source: /myorg/my-new-library # Must have llms.txt at root
techStacks:
  - typescript
teams:
  - platform
categories:
  - library
```

### Step 3: Ensure Repository is Indexed

Your repository must be indexed in the DHP AI Code Context service. Contact the DHPAI team to have your repository indexed if it's not already available.

You can check if a library is indexed by calling:

```
https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/api/search?query=my-library
```

That's it! No snippets, no local content needed.

## Limitations & Considerations

### Network Dependencies

- ⚠️ Requires DHP AI Code Context API to be accessible
- ⚠️ Fetching happens at runtime (slight latency)
- ⚠️ Only works within Hospital Authority network

### Service Dependencies

- ⚠️ Libraries must be indexed by DHP AI Code Context service
- ⚠️ Uses latest version by default (version selection not yet implemented)
- ⚠️ Dependent on DHP AI service uptime and availability

### CORS & Security

- ⚠️ Uses API proxy to avoid CORS issues
- ⚠️ All fetches go through `/api/contexts/llms-txt` endpoint
- ⚠️ Inherits security from DHP AI Code Context API

## Benefits Over Local Storage

✅ **Always Up-to-Date**: Content is never stale  
✅ **No Duplication**: Single source of truth  
✅ **Minimal Maintenance**: Only metadata needs updating  
✅ **Scalable**: Add unlimited libraries without repo bloat  
✅ **MCP-Compatible**: Same pattern as DHPAI Context MCP  
✅ **Version Flexibility**: Could support branch/tag selection in future

## Advanced Features

The DHP AI Code Context API supports additional query parameters:

### Topic Search

```
/{org}/{repo}/llms.txt?topic=authentication
```

Filters documentation to specific topics (default: "general")

### Token Budget

```
/{org}/{repo}/llms.txt?tokens=5000
```

Limits response size to approximate token count (default: 10000)

### Version Selection

```
/{org}/{repo}/{version}/llms.txt
```

Get documentation for specific version/tag/commit SHA

### Example URLs

```
# Latest version, general topic
https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/CMSCHASSIS/react-ui/llms.txt

# Specific topic
https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/CMSCHASSIS/react-ui/llms.txt?topic=button

# Limited tokens
https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/CMSCHASSIS/react-ui/llms.txt?tokens=5000

# Specific version
https://dhpai-code-context-poc-cms-dhp-1.tstcld61.server.ha.org.hk/CMSCHASSIS/react-ui/74892851/llms.txt
```

## Future Enhancements

Possible improvements:

- Add UI for topic selection
- Add UI for version selection
- Add token budget control
- Caching layer with TTL
- Direct MCP integration for RAG search
