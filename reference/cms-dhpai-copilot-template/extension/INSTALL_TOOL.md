# Install Tool Documentation

## Overview

The **DHPAI Install Tool** is a Language Model Tool that enables AI assistants to install DHPAI resources directly into your VS Code environment. This tool works seamlessly with the Search Tool to provide a complete discover-and-install workflow.

## Tool Information

- **Tool Name**: `install_dhpaiResources`
- **Reference Name**: `#installDHPAI`
- **Icon**: Cloud Download ($(cloud-download))

## What It Does

The install tool allows AI assistants to:

1. Install single or multiple DHPAI resources
2. Choose installation target (workspace, global, or copilot-instructions)
3. Identify resources by filename, title, or link
4. Batch install multiple resources at once
5. Provide confirmation before installation
6. Report success/failure for each resource

## Usage Examples

### For Users

Users can ask AI assistants to install resources naturally:

**Example 1: Install After Search**

```
User: "Find instructions about React testing and install them"
AI: *uses search tool* "Found React Unit Testing instructions..."
    *uses install tool* "✅ Successfully installed React Unit Testing"
```

**Example 2: Install Multiple Resources**

```
User: "Install all Java-related instructions to my workspace"
AI: *searches for Java instructions*
    *installs multiple at once*
    "✅ Successfully installed 3 resources:
      • Java Best Practices
      • Spring Boot Guidelines
      • JUnit Testing Instructions"
```

**Example 3: Install Globally**

```
User: "Install the Jest best practices globally so I can use it in all projects"
AI: *uses install tool with target='global'*
    "✅ Installed Jest best practices globally"
```

**Example 4: Direct Installation**

```
User: "Install react-unit-testing.instructions.md to my workspace"
AI: "✅ Successfully installed React Unit Testing (react-unit-testing.instructions.md)"
```

## API Reference

### Input Parameters

```typescript
{
  resources: string | string[];  // Required
  target?: 'workspace' | 'global' | 'copilot-instructions';  // Optional, default: 'workspace'
  category?: string;  // Optional filter
}
```

#### `resources` (Required)

Resource identifier(s) to install. Can be:

- **Filename**: `"react-unit-testing.instructions.md"`
- **Title**: `"React Unit Testing"`
- **Link**: `"instructions/react-unit-testing.instructions.md"`
- **Array**: `["file1.md", "file2.md"]` for batch installation

**Single resource:**

```json
{
	"resources": "react-unit-testing.instructions.md"
}
```

**Multiple resources:**

```json
{
	"resources": [
		"react-unit-testing.instructions.md",
		"jest-best-practices.instructions.md",
		"spring-boot-best-practices.instructions.md"
	]
}
```

#### `target` (Optional)

Installation destination:

| Value                  | Description                          | Location                                               |
| ---------------------- | ------------------------------------ | ------------------------------------------------------ |
| `workspace`            | Install to current project (default) | `.github/instructions/`, `.github/prompts/`, etc.      |
| `global`               | Install for all projects             | `~/.vscode/instructions/`, VS Code User prompts folder |
| `copilot-instructions` | Append to Copilot instructions       | `.github/copilot-instructions.md`                      |

**Examples:**

```json
// Install to workspace (default)
{ "resources": "file.md" }

// Install globally
{ "resources": "file.md", "target": "global" }

// Append to copilot-instructions
{ "resources": "file.md", "target": "copilot-instructions" }
```

#### `category` (Optional)

Filter by resource category for validation:

- `instructions`
- `prompts`
- `chatmodes`
- `agents`
- `collections`

```json
{
	"resources": "react-testing.md",
	"category": "instructions" // Only installs if it's an instruction
}
```

### Output Format

The tool returns a formatted summary:

**Success:**

```
✅ Successfully installed 2 resource(s):
  • React Unit Testing (react-unit-testing.instructions.md)
  • Jest Best Practices (jest-best-practices.instructions.md)
```

**With Failures:**

```
✅ Successfully installed 1 resource(s):
  • React Unit Testing (react-unit-testing.instructions.md)

❌ Failed to install 1 resource(s):
  • invalid-file.md: Resource not found
```

**All Failed:**

```
❌ Failed to install 2 resource(s):
  • invalid-file.md: Resource not found
  • wrong-category.md: Resource is in 'prompts' category, but filter requires 'instructions'
```

## How It Works

### Installation Flow

1. **Resource Identification**
   - Tool receives resource identifier(s)
   - Searches index for matching resources by filename, title, or link
   - Returns error if resource not found

2. **Content Fetching**
   - Fetches content from GitHub Enterprise
   - Uses existing authentication
   - Validates content availability

3. **Installation**
   - Installs to specified target location
   - Creates directories if needed
   - Handles conflicts and errors

4. **Confirmation**
   - User receives confirmation dialog before installation
   - Shows list of resources to be installed
   - Can be set to "Always Allow" for future installations

5. **Result Reporting**
   - Returns success/failure status for each resource
   - Provides detailed error messages
   - Shows installation paths

## Combined Workflow with Search Tool

The most powerful use case is combining search and install:

```
User: "Find and install all testing-related instructions"

Step 1: AI uses search tool
{
  "query": "testing",
  "category": "instructions",
  "limit": 10
}

Result:
- react-unit-testing.instructions.md
- jest-best-practices.instructions.md
- spring-boot-testing.instructions.md

Step 2: AI uses install tool
{
  "resources": [
    "react-unit-testing.instructions.md",
    "jest-best-practices.instructions.md",
    "spring-boot-testing.instructions.md"
  ],
  "target": "workspace"
}

Result: ✅ All 3 resources installed successfully
```

## User Confirmation

The tool implements user confirmation with:

**Title:** "Install DHPAI Resources"

**Message:**

```
Install 2 resource(s) to workspace?

Resources:
- `react-unit-testing.instructions.md`
- `jest-best-practices.instructions.md`
```

Users can:

- **Continue**: Proceed with installation
- **Cancel**: Abort the installation
- **Always Allow**: Skip confirmation for future installations

## Error Handling

Common errors and solutions:

### "Resource not found"

**Cause:** Identifier doesn't match any resource  
**Solution:** Use search tool first to get exact filename

### "Resource is in 'X' category, but filter requires 'Y'"

**Cause:** Category filter doesn't match resource type  
**Solution:** Remove category filter or use correct category

### "Failed to fetch content"

**Cause:** Network error or authentication issue  
**Solution:** Check authentication with `DHPAI: Explore and Install`

### "Failed to write file"

**Cause:** Permissions error  
**Solution:** Check file/directory permissions

## Caching

The install tool uses the same 5-minute cache as the search tool:

- Reduces API calls
- Improves performance
- Can be cleared with `DHPAI: Clear Search Cache` command

## Best Practices

### For AI Assistants

1. **Always search first** if the user doesn't provide exact identifiers
2. **Confirm resources** with the user before installing
3. **Use batch installation** when installing multiple resources
4. **Specify target** if user mentions global or copilot-instructions
5. **Report results** clearly to the user

### For Users

1. **Be specific** about what you want to install
2. **Specify target** if you want global installation
3. **Review confirmation** before proceeding
4. **Check results** to ensure successful installation

## Installation Locations

### Workspace Installation

```
.github/
├── instructions/
│   └── resource.instructions.md
├── prompts/
│   └── resource.prompt.md
├── agents/
│   └── resource.agent.md
└── copilot-instructions.md  (for target='copilot-instructions')
```

### Global Installation

```
~/.vscode/
└── instructions/
    └── resource.instructions.md

VS Code User Directory/
└── prompts/
    ├── resource.prompt.md
    ├── resource.agent.md
    └── resource.chatmode.md
```

## Troubleshooting

### Tool not working?

1. Check VS Code version (requires 1.85.0+, preferably Insiders)
2. Verify extension is activated
3. Check Output panel for errors
4. Ensure authentication is working

### Installation failed?

1. Check you're authenticated (`DHPAI: Explore and Install`)
2. Verify resource identifier is correct (use search tool)
3. Check file permissions
4. Look at error message for specific cause

## Integration Examples

### Example 1: Search and Install Workflow

```
User: "I need React testing instructions"

AI Response:
1. Searches for React testing resources
2. Finds "React Unit Testing" instruction
3. Asks: "Would you like me to install it?"
4. User confirms
5. Installs to workspace
6. Reports success
```

### Example 2: Batch Installation

```
User: "Set up my project with all Java best practices"

AI Response:
1. Searches for Java-related instructions
2. Finds multiple resources
3. Shows list to user
4. Installs all at once
5. Reports individual success/failure
```

### Example 3: Global Setup

```
User: "Install common prompts globally for all my projects"

AI Response:
1. Searches for commonly used prompts
2. Installs with target='global'
3. Resources available across all workspaces
```

## Related Tools

- **Search Tool** (`search_dhpaiResources`): Find resources to install
- **Manual Installation**: Use `DHPAI: Explore and Install` command

## Future Enhancements

Potential improvements:

- [ ] Update existing resources
- [ ] Uninstall resources
- [ ] List installed resources
- [ ] Backup before installation
- [ ] Installation templates
- [ ] Dry-run mode

## References

- [Language Model Tool API](https://code.visualstudio.com/api/extension-guides/ai/tools)
- [Search Tool Documentation](./LANGUAGE_MODEL_TOOL.md)
- [Extension README](./README.md)
