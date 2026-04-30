# CMS DHPAI React Generation Doc

Documentation for generating React applications using DHP AI MCP with Figma designs and HTML exports.

## Prerequisites

1. **VS Code** with **GitHub Copilot** installed
2. **Network access** to `*.server.ha.org.hk` (see Proxy Configuration below)

## Setup

### 1. Enable copilot timer tool

https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2991/93b52d80-dce7-4836-be53-f973b670969c

1. Download [copilot-timer](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/raw/copilot-timer/copilot-timer-0.0.3.vsix)
2. Drag and drop copilot-timer to VS Code Extension
3. After installed, click "Enable auto Start"

### 2. Install and configure the `dhpai` MCP

**Steps:**

1. In VS Code, press `Ctrl` + `Shift` + `P` and type "MCP", select **MCP: Add Server**

   ![Screenshot 2025-10-06 102810](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/feada64a-0af8-4320-814f-a2385a90d97c)

2. Select **HTTP**

   ![Screenshot 2025-10-06 102855](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/f6d504cc-9a2d-485d-96f8-2857ce09fe1c)

3. Enter the server URL:

   ```
   https://dhpai-context-mcp-poc-cms-dhp-1.tstcld61.server.ha.org.hk/sse
   ```

   ![Screenshot 2025-10-06 174027](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/fca2d9b4-a472-4803-832b-3c1272673fcd)

4. Enter server ID: `dhpai`

   ![Screenshot 2025-10-06 102955](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/f4ca5a27-9c15-434d-879f-f39e23c50145)

**Troubleshooting: Cannot connect MCP:**

If you cannot connect to the MCP, please run below commands in PowerShell to setup self-signed certificate.

![image](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2991/20494a08-1cb7-4cc4-8fbd-d6ae1dee2021)

```powershell
  setx NODE_OPTIONS "--use-openssl-ca"
  setx NODE_EXTRA_CA_CERTS "C:\\path\\to\\Hospital Authority Certificate"
```

### 2. Proxy / no-proxy configuration

- Add `.server.ha.org.hk` to your system no-proxy list
- If system no-proxy does not take effect, set the VS Code no-proxy setting to include `.server.ha.org.hk`

### 3. Recommended AI models

We suggest using **Claude Opus 4.5** as of December 16, 2025.

**Why these models?**

- **Advanced reasoning** – Complex multi-step React generation from Figma designs requires sophisticated reasoning and planning
- **Superior code quality** – Better understanding of modern React 18 patterns, TypeScript, component architecture, and clean code principles
- **Instruction adherence** – Proven ability to follow complex, layered instructions from `.github/instructions/`

## How it works

### GitHub Copilot Instructions

This repository includes GitHub Copilot instructions in `.github/instructions/` that **automatically guide code generation** when you work in this repository:

**No additional configuration needed** – GitHub Copilot automatically applies these instructions.

### Agents

Custom agents in `.github/agents/` provide specialized AI assistance:

**Greenfield React Generation Agent**
Generate new React applications from scratch using screenshot, Figma designs, exported HTML, or specifications.

**How to use:**

1. Click the chat modes button at the bottom left of the Copilot panel (default: "Agent")

![Screenshot 2025-12-16 175614](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/fddfe81f-06a9-47c7-ae1e-916d0397cd60)

2. Select the desired chat mode from the dropdown
3. The AI will follow specialized instructions and use appropriate tools for that mode

## Usage

1. In GitHub Copilot Chat, type `/` to open the prompt menu
2. Search for and select `/convert-design-to-react`
3. Attach your UI mockup screenshot and/or HTML files
4. Press Enter to start generation

### How to export screenshot from Figma

![Screenshot 2026-01-09 111122](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/155784ab-b57f-46d5-9732-9acf3770abe6)

1. Export screenshots from Figma by selecting a frame or layer
2. Navigate to the "Export" section in bottom of the right-hand panel
3. Click "+", and choosing formats like PNG, JPG, SVG, or PDF. Adjust scale (1x, 2x) for resolution
4. Click "Export" to save the file.

### How to export HTML from Figma

![Screenshot 2026-01-09 110742](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2197/14c4ce31-27ba-41e1-ab83-8db6bd381b80)

1. Rght click the layer you want to export from the "Layer" panel on the left
2. Select "Plugins" and then "Manage plugins..."
3. Search for "AutoHTML"
4. Follow the instruction provided to export the HTML files.
