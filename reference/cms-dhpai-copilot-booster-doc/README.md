# DHPAI Copilot Instruction

DHPAI Copilot Instruction is a custom instruction for VS Code agent that adds an opinionated workflow to the agent, including use of a todo list, extensive internet research capabilities, planning, tool usage instructions and more. Designed to be used with GPT 4.1, although it will work with any model.

## Setup

You can set it up via **Chat Modes** or **Custom Instructions**:

- **Chat Modes**: Switch between different modes as needed
- **Custom Instructions**: Applied to every request across all chat modes

### Chat Modes Setup (Recommended)

1. **Download** the [`DHPAI.chatmode.md`](./DHPAI.chatmode.md) file
2. **Open Chat Modes**: Click the Agent/Chat dropdown at the bottom left of Copilot Chat
3. **Configure**: Select "Configure Modes"
4. **Create Mode**: Choose location (Project/User) and name it "DHPAI"
5. **Import**: Paste the downloaded file content

### Custom Instructions Setup

1. **Download** the [`DHPAI.chatmode.md`](./DHPAI.chatmode.md) file
2. **Open Command Palette**: `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
3. **Search**: Type "instruction"
4. **Select**: "Chat: New Instructions File..."
5. **Create**: Choose location (Project/User) and name it "DHPAI"
6. **Import**: Paste the downloaded file content

## Usage

### Chat Modes

Click the dropdown menu on the bottom-left corner of your Copilot Chat, then select DHPAI

![Screenshot 2025-08-14 121910](https://hagithub.home/CMS/cms-dhpai-copilot-booster-doc/assets/2197/a4654d9e-3ec4-4e38-a958-ca7ffba82170)

### Custom Instructions

1. Click the "Add Context" button in your Copilot Chat, then select "Instructions"
   ![Screenshot 2025-08-14 122130](https://hagithub.home/CMS/cms-dhpai-copilot-booster-doc/assets/2197/ffe7d9d5-b24e-41a4-a28f-2118f5aa1016)
2. Select "DHPAI"
   ![Screenshot 2025-08-14 122217](https://hagithub.home/CMS/cms-dhpai-copilot-booster-doc/assets/2197/5ee6cc02-c14f-4ad1-b90f-b0d91924265f)

## Recommended VS Code Settings

Because agent mode depends heavily on tool calling, it's recommended that you turn on "Auto Approve" in the settings. Note that this will allow the agent to execute commands in your terminal without asking for permission. I also recommend bumping "Max Requests" to 300 to keep the agent working on long running tasks without asking you if you want it to continue. You can do that through the settings UI or via your user settings json file.

```json
{
	"chat.tools.autoApprove": true,
	"chat.agent.maxRequests": 300
}
```
