# Language Model Tool: DHPAI Search

This document describes the DHPAI Search Tool that enables AI assistants (like GitHub Copilot) to search and filter DHPAI resources directly within VS Code.

## Overview

The DHPAI Search Tool is a **Language Model Tool** that allows AI assistants to:

- Search instructions, prompts, chatmodes, agents, and collections
- Filter by category
- Find resources by keywords in titles and descriptions
- Return formatted results without needing full content

## How It Works

### Architecture

1. **Registration**: The tool is registered using `vscode.lm.registerTool()` during extension activation
2. **Discovery**: AI assistants automatically discover the tool through VS Code's Language Model API
3. **Invocation**: When users ask questions, the AI decides whether to use the tool
4. **Caching**: Results are cached for 5 minutes to improve performance

### Components

#### 1. Tool Definition (`extension/src/searchTool.ts`)

- **Class**: `DHPAISearchTool`
- **Tool ID**: `dhpai_searchResources`
- **Capabilities**:
  - Full-text search across all resources
  - Category filtering
  - Result limiting
  - Smart caching

#### 2. Package.json Contribution

```json
{
  "contributes": {
    "languageModelTools": [
      {
        "name": "dhpai_searchResources",
        "displayName": "Search DHPAI Resources",
        "description": "Search and filter DHPAI instructions, prompts, chatmodes, agents, and collections",
        "modelDescription": "...",
        "inputSchema": { ... }
      }
    ]
  }
}
```

## Usage Examples

### For Users

Users don't need to explicitly invoke the tool. They simply ask questions naturally:

**Example 1: General Search**

```
User: "Find instructions about unit testing"
AI: *automatically uses the search tool* "Found 2 instructions about unit testing..."
```

**Example 2: Category-Specific Search**

```
User: "Show me all React prompts"
AI: *uses search with category filter* "Here are the React-related prompts..."
```

**Example 3: List All Resources**

```
User: "What instructions are available?"
AI: *searches without query to list all* "Available instructions include..."
```

### For Developers

The tool can be invoked programmatically:

```typescript
const result = await vscode.lm.invokeTool("dhpai_searchResources", {
	toolInvocationToken: undefined,
	input: {
		query: "testing",
		category: "instructions",
		limit: 5,
	},
});
```

## API Reference

### Input Schema

```typescript
interface SearchParameters {
	query?: string; // Search query (optional)
	category?: string; // One of: instructions, prompts, chatmodes, agents, collections
	limit?: number; // Max results (default: 10)
}
```

### Examples

**Search all resources:**

```json
{
	"query": "testing"
}
```

**Search specific category:**

```json
{
	"query": "React",
	"category": "prompts",
	"limit": 5
}
```

**List all in category:**

```json
{
	"category": "instructions",
	"limit": 20
}
```

### Output Format

The tool returns formatted text:

```
Found 3 resource(s):

1. **Unit Test Generation** (instructions)
   Description: Guidelines for generating comprehensive unit tests
   File: cms-dhpai-unit-test-generation-doc.instructions.md

2. **React Unit Testing** (instructions)
   Description: Best practices for testing React components
   File: react-unit-testing.instructions.md

3. **Jest Best Practices** (instructions)
   Description: Patterns and practices for Jest testing
   File: jest-best-practices.instructions.md
```

## Features

### 1. Intelligent Caching

- **Duration**: 5 minutes
- **Benefits**: Reduces API calls, faster responses
- **Invalidation**: Manual via `DHPAI: Clear Search Cache` command

### 2. Relevance Sorting

- Title matches ranked higher than description matches
- Multi-term searches require all terms to match

### 3. Progress Indication

The `prepareInvocation` method provides context-aware progress messages:

- "Searching instructions for 'testing'..."
- "Searching all DHPAI resources for 'React'..."

### 4. Error Handling

Graceful error handling with informative messages returned to the AI

## Commands

### `dhpai.clearCache`

**Title**: DHPAI: Clear Search Cache  
**Purpose**: Manually clear the search cache to force fresh data fetch

## Configuration

### Required Settings

1. **VS Code Version**: `^1.85.0` or higher
2. **API Proposals**: `lm-tools` enabled in `package.json`

```json
{
	"engines": {
		"vscode": "^1.85.0"
	},
	"enabledApiProposals": ["lm-tools"]
}
```

### Extension Settings

The tool uses existing DHPAI settings:

- `dhpai.baseUrl`: GitHub Enterprise base URL
- `dhpai.repository`: Repository path
- `dhpai.branch`: Branch name

## Development

### Adding New Features

To extend the search tool:

1. **Modify SearchParameters** in `searchTool.ts`
2. **Update inputSchema** in `package.json`
3. **Implement logic** in the `search()` method
4. **Update formatResults()** if needed

### Testing

**Manual Testing:**

```bash
cd extension
npm run compile
```

Then press F5 in VS Code to launch Extension Development Host.

**Test Scenarios:**

1. Ask Copilot: "Find instructions about Java"
2. Ask Copilot: "Show me all available prompts"
3. Ask Copilot: "What collections do you have?"

## Troubleshooting

### Tool Not Available

- **Issue**: AI doesn't see the tool
- **Solution**: Ensure VS Code version is ^1.85.0 and `lm-tools` API proposal is enabled

### Search Returns No Results

- **Issue**: Valid resources not found
- **Solutions**:
  - Clear cache: Run `DHPAI: Clear Search Cache`
  - Check authentication: Run `DHPAI: Explore and Install` to verify connection
  - Verify repository settings in VS Code settings

### Compilation Errors

- **Issue**: TypeScript compilation fails
- **Solution**: Ensure `@types/vscode` is version `^1.85.0` or higher

## Best Practices

### For Extension Developers

1. **Keep inputSchema in sync** between `package.json` and TypeScript types
2. **Implement prepareInvocation** for better UX with progress messages
3. **Use caching wisely** to balance freshness and performance
4. **Handle errors gracefully** to provide useful feedback to AI

### For AI Assistants

The tool is most effective when:

- User asks about available resources
- User wants to search for specific topics
- User needs to filter by resource type
- User wants quick overview without full content

## Future Enhancements

Potential improvements:

- [ ] Support for fuzzy matching
- [ ] Advanced filters (tags, authors, dates)
- [ ] Similarity-based search
- [ ] Integration with semantic search
- [ ] Support for custom ranking algorithms
- [ ] Batch search operations

## References

- [VS Code Language Model API](https://code.visualstudio.com/api/extension-guides/language-model)
- [VS Code Extension API](https://code.visualstudio.com/api)
- [DHPAI Extension Documentation](./README.md)
