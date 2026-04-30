# 🤖 CMS DHP AI Copilot Documentation

[![Powered by CMS DHP AI Copilot](https://img.shields.io/badge/Powered_by-CMS_DHP_AI_Copilot-blue?logo=githubcopilot)](https://hagithub.home/CMS/cms-dhpai-copilot-doc)

A curated collection of prompts, instructions, and chat modes to supercharge your GitHub Copilot experience across different domains, languages, and use cases.

## 🚀 What is CMS DHP AI Copilot Documentation?

This repository provides a comprehensive toolkit for enhancing GitHub Copilot with specialized:

- **[![Awesome Prompts](https://img.shields.io/badge/Awesome-Prompts-blue?logo=githubcopilot)](README.prompts.md)** - Focused, task-specific prompts for generating code, documentation, and solving specific problems
- **[![Awesome Instructions](https://img.shields.io/badge/Awesome-Instructions-blue?logo=githubcopilot)](README.instructions.md)** - Comprehensive coding standards and best practices that apply to specific file patterns or entire projects
- **[![Awesome Chat Modes](https://img.shields.io/badge/Awesome-Chat_Modes-blue?logo=githubcopilot)](README.chatmodes.md)** - Specialized AI personas and conversation modes for different roles and contexts

## MCP Server

To make it easy to add these customizations to your editor, we have created a [MCP Server](https://developer.microsoft.com/blog/announcing-awesome-copilot-mcp-server) that provides a prompt for searching and installing prompts, instructions, and chat modes directly from this repository.

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://aka.ms/awesome-copilot/mcp/vscode) [![Install in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install-24bfa5?style=flat-square&logo=visualstudiocode&logoColor=white)](https://aka.ms/awesome-copilot/mcp/vscode-insiders)

<details>
<summary>Show MCP Server JSON configuration</summary>

```json
{
	"servers": {
		"awesome-copilot": {
			"type": "stdio",
			"command": "docker",
			"args": [
				"run",
				"-i",
				"--rm",
				"ghcr.io/microsoft/mcp-dotnet-samples/awesome-copilot:latest"
			]
		}
	}
}
```

</details>

## 🔧 How to Use

### 🎯 Prompts

Use the `/` command in GitHub Copilot Chat to access prompts:

```
/awesome-copilot create-readme
```

### 📤 Push via MCP (Enterprise)

If direct git push is blocked, you can push via MCP API with a single commit containing all files. This repository was prepared to support that workflow.

## 📚 Additional Resources

- [VS Code Copilot Customization Documentation](https://code.visualstudio.com/docs/copilot/copilot-customization) - Official Microsoft documentation
- [GitHub Copilot Chat Documentation](https://code.visualstudio.com/docs/copilot/chat/copilot-chat) - Complete chat feature guide
- [Custom Chat Modes](https://code.visualstudio.com/docs/copilot/chat/chat-modes) - Advanced chat configuration
- [VS Code Settings](https://code.visualstudio.com/docs/getstarted/settings) - General VS Code configuration guide

## ™️ Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
