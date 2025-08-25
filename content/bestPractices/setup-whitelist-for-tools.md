# Setup Whitelist for Tools

Allowing an AI assistant to run commands on your machine can be a huge productivity booster, but it also comes with security risks. A whitelist is a powerful tool for balancing convenience and safety. This guide explains how to set it up effectively.

## The Risk of "YOLO"

"YOLO" (You Only Live Once) mode means automatically approving every command an AI assistant suggests without review. While it might seem convenient, it is extremely risky. An AI can make mistakes or be tricked, and letting it run commands unchecked can lead to:

- **Data Loss:** Accidentally deleting important files.
- **Security Breaches:** Exposing sensitive data or creating vulnerabilities.
- **System Instability:** Damaging critical system configurations.

For these reasons, you should never fully trust an AI with unattended access to your terminal. Always review commands that can modify your system.

## The Convenience of Auto-Allowing Read-Only Commands

Auto-allowing read-only commands like `ls`, `cat`, `grep`, `git status`, `pwd`, and read-only MCP commands for `HA Context` or `context7` is a safe way to improve efficiency. By whitelisting them, you can:

-   **Speed Up Your Workflow:** Get instant answers from commands that inspect your codebase.
-   **Reduce Distractions:** Avoid unnecessary approval prompts for harmless commands.
-   **Stay Focused:** Keep your attention on your work, not on managing your tools.

## How to Setup a Whitelist for Commands

By default, when a tool is invoked, you need to confirm the action before it is run. This is because tools might run locally on your machine and might perform actions that modify files or data.

Use the Always Allow options to automatically confirm the specific tool for the current session, workspace, or all future invocations.

![](/images/mcp-tool-confirmation.png)
