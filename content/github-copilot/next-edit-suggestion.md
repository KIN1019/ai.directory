# Next Edit Suggestion

Next edit suggestion is a feature in GitHub Copilot that allows you to ask Copilot to suggest the next edit in your code. This feature is particularly useful when you are working on a code file and want to quickly generate the next logical step or modification based on the current context of your code.

## Enable Next Edit Suggestion in VS Code Using Settings (GUI)

To enable the next edit suggestion feature in VS Code using the graphical user interface, follow these steps:

1. Open VS Code and go to the settings by clicking on the gear icon in the lower left corner or by pressing `Ctrl + ,`.
2. In the search bar at the top of the settings panel, type `Copilot`.
3. Look for the setting named `Next Edit Suggestion`.
4. Check the box next to this setting to enable it.
5. You can check the bottom right corner of the VS Code window to see if the next edit suggestion feature is enabled. If it is, you will see a Copilot icon with a message indicating that next edit suggestions are available.

## Enable Next Edit Suggestion in VS Code Using Settings (JSON)

To enable the next edit suggestion feature in VS Code, follow these steps:

1. Open the command palette (Ctrl+Shift+P) and search for "Preferences: Open Settings (JSON)".
2. In the settings.json file, add the following configuration:

```json
{
	"github.copilot.chat.nextEditSuggestion.enabled": true
}
```

3. Save the settings.json file and restart VS Code.
