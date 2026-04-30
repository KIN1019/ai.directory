# vscode:// Installation Links

One-click installation links that open VS Code and automatically install items.

## Overview

You can create special `vscode://` links that, when clicked:

1. Open VS Code (if not already open)
2. Authenticate user (if needed)
3. Download the item from GitHub Enterprise
4. Install it globally, to workspace, or show preview
5. Open the installed file

Perfect for:

- 📄 Documentation websites
- 📧 Email sharing
- 💬 Chat messages (Teams, Slack)
- 📋 Wiki pages
- 🎓 Training materials

## Link Format

### Basic Format

```
vscode://publisher-name.awesome-copilot-ghe/install?type=TYPE&link=PATH&target=TARGET
```

### Parameters

| Parameter | Required | Values                                                     | Description                       |
| --------- | -------- | ---------------------------------------------------------- | --------------------------------- |
| `type`    | ✅ Yes   | `instruction`, `prompt`, `agent`, `chatmode`, `collection` | Type of item                      |
| `link`    | ✅ Yes   | Relative path                                              | Path to the item in repository    |
| `target`  | ❌ No    | `global`, `workspace`, `view`, `ask`                       | Where to install (default: `ask`) |

### Target Options

- **`global`**: Install to user directory (available in all workspaces)
- **`workspace`**: Install to current workspace `.github/` folders
- **`view`**: Open in editor without installing
- **`ask`**: Prompt user to choose (default)

## Examples

### Install Instruction Globally

```
vscode://your-publisher.awesome-copilot-ghe/install?type=instruction&link=instructions/java-best-practices.instructions.md&target=global
```

### Install Prompt to Workspace

```
vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/unit-test-generator.prompt.md&target=workspace
```

### View Agent (No Install)

```
vscode://your-publisher.awesome-copilot-ghe/install?type=agent&link=chatmodes/senior-developer.chatmode.md&target=view
```

### Install Collection (Ask User)

```
vscode://your-publisher.awesome-copilot-ghe/install?type=collection&link=collections/react-bundle.collection.yml&target=ask
```

### Prompt User Where to Install

```
vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/code-review.prompt.md
```

_(Omit `target` parameter or use `target=ask`)_

## Creating Links

### Method 1: Manual Construction

Replace these placeholders:

- `{publisher-name}`: Your VS Code publisher name (from `package.json`)
- `{type}`: instruction, prompt, agent, or collection
- `{path}`: Path to item (e.g., `prompts/example.prompt.md`)
- `{target}`: global, workspace, view, or ask

```
vscode://{publisher-name}.awesome-copilot-ghe/install?type={type}&link={path}&target={target}
```

### Method 2: Using the Link Generator Script

Create a helper script (see below) to generate links automatically.

## Using Links in Different Contexts

### In HTML

```html
<a
	href="vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/test-gen.prompt.md&target=global"
>
	📥 Install Test Generator
</a>
```

### In Markdown

```markdown
[📥 Install Java Best Practices](vscode://your-publisher.awesome-copilot-ghe/install?type=instruction&link=instructions/java-best-practices.instructions.md&target=global)
```

### In VS Code Hover/Documentation

```typescript
/**
 * Example function
 *
 * [Install related prompt](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/function-docs.prompt.md)
 */
```

### In README Badge

```markdown
[![Install](https://img.shields.io/badge/Install-VS%20Code-blue)](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/example.prompt.md&target=ask)
```

### In GitHub Issues/PRs

```markdown
Try this prompt: [Install in VS Code](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/fix-bug.prompt.md)
```

## Link Generator Script

Create `scripts/generate-link.js`:

```javascript
#!/usr/bin/env node

// Configuration
const PUBLISHER = "your-publisher-name";
const EXTENSION = "awesome-copilot-ghe";

function generateLink(type, path, target = "ask") {
	const baseUrl = `vscode://${PUBLISHER}.${EXTENSION}/install`;
	const params = new URLSearchParams({
		type,
		link: path,
		target,
	});
	return `${baseUrl}?${params.toString()}`;
}

// Parse command line arguments
const args = process.argv.slice(2);
if (args.length < 2) {
	console.log("Usage: node generate-link.js <type> <path> [target]");
	console.log(
		"Example: node generate-link.js prompt prompts/example.prompt.md global",
	);
	process.exit(1);
}

const [type, path, target] = args;
const link = generateLink(type, path, target);

console.log("Generated link:");
console.log(link);
console.log("\nMarkdown:");
console.log(`[Install ${path.split("/").pop()}](${link})`);
console.log("\nHTML:");
console.log(`<a href="${link}">Install ${path.split("/").pop()}</a>`);
```

Usage:

```bash
node scripts/generate-link.js prompt prompts/test-gen.prompt.md global
```

Output:

```
Generated link:
vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts%2Ftest-gen.prompt.md&target=global

Markdown:
[Install test-gen.prompt.md](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts%2Ftest-gen.prompt.md&target=global)

HTML:
<a href="vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts%2Ftest-gen.prompt.md&target=global">Install test-gen.prompt.md</a>
```

## Python Link Generator

```python
#!/usr/bin/env python3
from urllib.parse import urlencode

PUBLISHER = 'your-publisher-name'
EXTENSION = 'awesome-copilot-ghe'

def generate_link(type, path, target='ask'):
    base_url = f'vscode://{PUBLISHER}.{EXTENSION}/install'
    params = urlencode({'type': type, 'link': path, 'target': target})
    return f'{base_url}?{params}'

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print('Usage: python generate-link.py <type> <path> [target]')
        sys.exit(1)

    type = sys.argv[1]
    path = sys.argv[2]
    target = sys.argv[3] if len(sys.argv) > 3 else 'ask'

    link = generate_link(type, path, target)
    filename = path.split('/')[-1]

    print('Generated link:')
    print(link)
    print('\nMarkdown:')
    print(f'[Install {filename}]({link})')
    print('\nHTML:')
    print(f'<a href="{link}">Install {filename}</a>')
```

## Building a Catalog Page

Create an HTML catalog page with install buttons:

```html
<!DOCTYPE html>
<html>
	<head>
		<title>Awesome Copilot Catalog</title>
		<style>
			.item {
				border: 1px solid #ddd;
				padding: 15px;
				margin: 10px 0;
				border-radius: 5px;
			}
			.install-btn {
				background-color: #007acc;
				color: white;
				padding: 8px 16px;
				text-decoration: none;
				border-radius: 4px;
				display: inline-block;
				margin-right: 10px;
			}
			.install-btn:hover {
				background-color: #005a9e;
			}
		</style>
	</head>
	<body>
		<h1>📚 Awesome Copilot Catalog</h1>

		<div class="item">
			<h3>Java Best Practices</h3>
			<p>Enterprise Java coding standards and patterns</p>
			<a
				class="install-btn"
				href="vscode://your-publisher.awesome-copilot-ghe/install?type=instruction&link=instructions/java-best-practices.instructions.md&target=global"
			>
				📥 Install Globally
			</a>
			<a
				class="install-btn"
				href="vscode://your-publisher.awesome-copilot-ghe/install?type=instruction&link=instructions/java-best-practices.instructions.md&target=workspace"
			>
				📁 Install to Workspace
			</a>
			<a
				class="install-btn"
				href="vscode://your-publisher.awesome-copilot-ghe/install?type=instruction&link=instructions/java-best-practices.instructions.md&target=view"
			>
				👁️ Preview
			</a>
		</div>

		<div class="item">
			<h3>Unit Test Generator</h3>
			<p>Generate comprehensive unit tests</p>
			<a
				class="install-btn"
				href="vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/unit-test-generator.prompt.md&target=ask"
			>
				📥 Install
			</a>
		</div>

		<!-- Add more items -->
	</body>
</html>
```

## QR Codes

Generate QR codes for physical documentation:

```bash
# Using qrencode (install: apt-get install qrencode)
qrencode -o install-prompt.png "vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/example.prompt.md"
```

Users can scan the QR code with their phone and open the link on their computer.

## URL Shorteners

For cleaner links in presentations or printed materials:

```bash
# Original long link
vscode://your-publisher.awesome-copilot-ghe/install?type=instruction&link=instructions/java-best-practices.instructions.md&target=global

# Shortened (using your organization's URL shortener)
https://company.short/java-best-practices
→ redirects to vscode:// link
```

## Embedding in VS Code

### In Extension Documentation

```markdown
## Getting Started

Install our recommended prompts:

- [Code Review Prompt](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/code-review.prompt.md)
- [Test Generator](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/test-gen.prompt.md)
```

### In Hover Providers

```typescript
const hoverContent = new vscode.MarkdownString();
hoverContent.isTrusted = true; // Required for command links
hoverContent.value = `
Install related prompt: [Unit Test Generator](vscode://your-publisher.awesome-copilot-ghe/install?type=prompt&link=prompts/test-gen.prompt.md&target=workspace)
`;
```

## Security Considerations

### What Users See

When clicking a vscode:// link:

1. VS Code opens (if not already open)
2. Extension activates
3. User is prompted to authenticate (if not logged in)
4. User can choose where to install (if `target=ask`)
5. Content is fetched and installed

### No Silent Installation

- Users always see what's being installed
- Users can cancel at any point
- Authentication is required
- Links don't execute arbitrary code

### Link Validation

The extension validates:

- User is authenticated
- Content exists in GitHub Enterprise
- User has access to the repository
- Installation location is valid

## Troubleshooting

### Link Doesn't Open VS Code

**Cause**: VS Code protocol handler not registered

**Solution**:

1. Ensure VS Code is installed
2. Reinstall the extension
3. On some systems, run: `code --register-protocol-handler`

### "Invalid installation link"

**Cause**: Missing required parameters

**Solution**: Ensure link has both `type` and `link` parameters

### Authentication Required Every Time

**Cause**: Not logged in or token expired

**Solution**: Run `Awesome Copilot: Explore` once to authenticate

### Link Opens Wrong Extension

**Cause**: Publisher name mismatch

**Solution**: Verify publisher name in link matches `package.json`

## Best Practices

### ✅ Do

- Include descriptive text around links
- Test links before sharing
- Use `target=ask` for new users
- Provide alternative manual installation steps
- Keep links in version control

### ❌ Don't

- Use URL shorteners that hide the destination
- Share links to private content publicly
- Hardcode `target=workspace` without context
- Create excessively long parameter values
- Forget to URL-encode special characters

## Advanced: Dynamic Link Generation

Generate links dynamically from your index.json:

```javascript
const fs = require("fs");
const index = JSON.parse(fs.readFileSync("index.json"));

const PUBLISHER = "your-publisher";
const EXTENSION = "awesome-copilot-ghe";

function generateCatalog() {
	let markdown = "# Awesome Copilot Catalog\n\n";

	["instructions", "prompts", "agents"].forEach((category) => {
		markdown += `## ${category.charAt(0).toUpperCase() + category.slice(1)}\n\n`;

		index[category].forEach((item) => {
			const link = `vscode://${PUBLISHER}.${EXTENSION}/install?type=${category.slice(0, -1)}&link=${encodeURIComponent(item.link)}&target=ask`;
			markdown += `- **${item.title}**: ${item.description} [Install](${link})\n`;
		});

		markdown += "\n";
	});

	return markdown;
}

fs.writeFileSync("CATALOG.md", generateCatalog());
console.log("Generated CATALOG.md");
```

## Summary

vscode:// links provide a seamless way to share and install Copilot items:

- ✅ One-click installation
- ✅ Works in any context (web, docs, chat)
- ✅ Secure (requires authentication)
- ✅ Flexible (global, workspace, or preview)
- ✅ User-friendly (VS Code handles everything)

Share these links to make it easy for your team to adopt best practices and standardized prompts!
