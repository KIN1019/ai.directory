# Troubleshooting Language Model Tools

## Issue: Tool Not Appearing in Copilot

### Step 1: Check VS Code Version

The `lm-tools` API proposal requires **VS Code 1.85.0 or higher**, and may only work in **VS Code Insiders**.

**Check your version:**

1. Open VS Code
2. Go to `Help` > `About`
3. Check the version number

**Required:**

- VS Code Insiders 1.85.0+ (Recommended)
- OR VS Code Stable 1.85.0+ (if API is stabilized)

**If using Stable VS Code:**

- The `lm-tools` API may still be in preview
- You might need to switch to **VS Code Insiders**
- Download from: https://code.visualstudio.com/insiders/

### Step 2: Reinstall the Extension

1. **Uninstall old version:**

   ```bash
   code --uninstall-extension dhpai.dhpai
   # or for Insiders
   code-insiders --uninstall-extension dhpai.dhpai
   ```

2. **Install new version:**

   ```bash
   code --install-extension extension/dhpai-1.0.0.vsix
   # or for Insiders
   code-insiders --install-extension extension/dhpai-1.0.0.vsix
   ```

3. **Restart VS Code completely**

### Step 3: Verify Extension Activated

1. Open VS Code
2. Open **Output** panel: `View` > `Output`
3. Select **"Log (Extension Host)"** from dropdown
4. Look for:
   ```
   DHPAI extension is now active
   DHPAI search tool registered successfully
   ```

**If you see errors:**

- Check the error message
- The API might not be available in your VS Code version

### Step 4: Check Extension Status

1. Open Command Palette (`Ctrl+Shift+P`)
2. Type: `Developer: Show Running Extensions`
3. Find **"DHPAI"** in the list
4. It should show:
   - Status: **Activated**
   - Activation Events: `onStartupFinished`

**If NOT activated:**

- Try running a DHPAI command: `DHPAI: Explore and Install`
- Check Output panel for errors

### Step 5: Verify Tool Registration

Open the **Developer Tools Console**:

1. `Help` > `Toggle Developer Tools`
2. Go to **Console** tab
3. Type and run:
   ```javascript
   vscode.lm.tools;
   ```
4. Look for `dhpai_searchResources` in the array

**Expected output:**

```javascript
[
  {
    name: "dhpai_searchResources",
    description: "Search and filter DHPAI resources...",
    ...
  }
]
```

### Step 6: Check Copilot Chat

The tool appears in different places depending on your setup:

**Option 1: In Copilot Chat**

1. Open Copilot Chat
2. Type `@workspace` or just start a conversation
3. Ask: "What DHPAI instructions are available?"
4. Copilot should automatically invoke the tool

**Option 2: Tool Attachment (if supported)**

1. In Copilot Chat input
2. Look for a tool attachment icon or `#` symbol
3. You might see available tools listed

**Note:** Tools are often used automatically by the AI without showing in a UI list.

## Common Issues

### Issue: "lm-tools API not available"

**Cause:** VS Code version doesn't support the API

**Solution:**

1. Update to VS Code 1.85.0+
2. Or switch to VS Code Insiders
3. Check if the API is stabilized in release notes

### Issue: Extension not activating

**Cause:** Activation events not triggering

**Solution:**

1. Run any DHPAI command manually first
2. Check `activationEvents` in package.json includes `"onStartupFinished"`
3. Reinstall the extension

### Issue: Tool registered but not used

**Cause:** AI doesn't see the tool as relevant

**Solution:**

1. Be specific in your questions
2. Try: "Use the DHPAI search tool to find instructions about testing"
3. The tool description might need improvement

### Issue: API Proposals Warning

**Error:** "Extension uses proposed API..."

**Cause:** Proposed APIs require special flags

**Solution for Development:**

1. Use Extension Development Host (F5)
2. The extension includes `enabledApiProposals` in package.json

**Solution for Production:**

- Wait for API stabilization
- Or distribute only to users with Insiders builds

## Verifying Tool Works

### Test 1: Manual Invocation

In Developer Tools Console:

```javascript
// Get tool information
vscode.lm.tools.find((t) => t.name === "dhpai_searchResources");

// Invoke the tool (if API allows)
vscode.lm.invokeTool("dhpai_searchResources", {
	toolInvocationToken: undefined,
	input: { query: "testing", limit: 3 },
});
```

### Test 2: Through Copilot

Ask Copilot these questions:

1. "Find DHPAI instructions about unit testing"
2. "Show me all available DHPAI prompts"
3. "What DHPAI collections are available?"

Watch the Output panel for tool invocation logs.

### Test 3: Check Tool Cache

Run command: `DHPAI: Clear Search Cache`

If this works, the extension is active and tool is functional.

## Alternative: Check if API is Available

Create a test extension to verify the API:

```typescript
// In extension.ts
export function activate(context: vscode.ExtensionContext) {
	// Check if lm namespace exists
	if (typeof vscode.lm === "undefined") {
		console.error("vscode.lm API not available");
		vscode.window.showErrorMessage(
			"Language Model API not available in this VS Code version",
		);
		return;
	}

	console.log("vscode.lm API is available");
	console.log("Registered tools:", vscode.lm.tools);
}
```

## Known Limitations

### 1. VS Code Version Requirements

- API may be Insiders-only
- Check VS Code release notes for API status

### 2. Proposed API Restrictions

- Extensions using proposed APIs can't be published to marketplace
- Only work in development or with special configuration

### 3. Tool Visibility

- Tools may not show in a UI list
- They're used automatically by AI assistants
- No manual "tool picker" in current implementation

## Getting Help

If tool still doesn't appear:

1. **Check VS Code version:**

   ```bash
   code --version
   ```

2. **Check extension logs:**
   - Output panel > "Log (Extension Host)"
   - Look for "DHPAI" messages

3. **Check Developer Console:**
   - Help > Toggle Developer Tools
   - Look for JavaScript errors

4. **Verify file exists:**

   ```bash
   ls extension/out/searchTool.js
   ```

5. **Check package.json:**
   - Verify `enabledApiProposals` includes `"lm-tools"`
   - Verify `activationEvents` includes `"onStartupFinished"`

## Success Indicators

✅ Extension shows as "Activated" in Running Extensions  
✅ Console log shows "DHPAI search tool registered successfully"  
✅ `vscode.lm.tools` includes `dhpai_searchResources`  
✅ Copilot automatically uses the tool when asked relevant questions  
✅ No errors in Output or Console

## Next Steps

If you've verified everything above:

1. The tool IS working but Copilot uses it automatically
2. There may not be a visible UI list of tools
3. Try asking Copilot questions and watch for tool usage
4. Check if your VS Code version fully supports the API
