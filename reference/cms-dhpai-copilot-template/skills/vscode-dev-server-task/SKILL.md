---
name: vscode-dev-server-task
description: "Use VS Code tasks to manage dev servers in multi-agent environments, preventing duplicate processes, replacing `npm run dev`"
---

When multiple AI agents operate in parallel, each agent runs in an isolated context without awareness of other agents' actions. This means one agent may attempt to start a dev server while another has already started one, resulting in wasted system resources from duplicate server processes. To prevent this, always use the VS Code task system to start the dev server instead of running `npm run dev` directly in the terminal. The task system acts as a singleton manager—if a dev server is already running, VS Code will reuse the existing task rather than spawning a new process.

Create or edit `.vscode/tasks.json` in the project root with the following content:

```json
{
	"version": "2.0.0",
	"tasks": [
		{
			"label": "Start Dev Server",
			"type": "npm",
			"script": "dev",
			"problemMatcher": [],
			"presentation": {
				"reveal": "always",
				"panel": "dedicated",
				"clear": true
			},
			"isBackground": true
		}
	]
}
```

To start the dev server, use #tool:runTasks/runTask to run the "Start Dev Server" task instead of executing terminal commands like `npm run dev`. #tool:runTasks/runTask communicates with VS Code's task runner, which tracks active tasks and prevents duplicate execution—if the task is already running, VS Code simply brings the existing terminal panel into focus rather than spawning a new process. To inspect the server's output (e.g., the local URL, compilation errors, or hot-reload status), use #tool:runTasks/getTaskOutput . This is particularly useful when you need to verify the server started successfully or diagnose build failures.

NEVER run `npm run dev` or similar commands directly in the terminal if necessary.
