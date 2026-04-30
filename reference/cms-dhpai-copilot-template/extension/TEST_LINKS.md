# Test vscode:// Installation Links

Use these links to test the extension. **Ctrl+Click** (or Cmd+Click on Mac) to open.

## ⚠️ Important: Update Publisher Name

Replace `your-publisher-name` in the links below with your actual publisher name from `package.json`!

## 🧪 Quick Test Links

### Instructions (Ask Where to Install)

- [Install Java Developer Instructions](vscode://your-publisher-name.awesome-copilot-ghe/install?type=instruction&link=instructions/ha-java-developer.instructions.md&target=ask)
- [Install Frontend Developer Instructions](vscode://your-publisher-name.awesome-copilot-ghe/install?type=instruction&link=instructions/ha-frontend-developer.instructions.md&target=ask)

### Instructions (Install Globally)

- [Install Unit Test Generation (Global)](vscode://your-publisher-name.awesome-copilot-ghe/install?type=instruction&link=instructions/cms-dhpai-unit-test-generation-doc.instructions.md&target=global)
- [Install Mobile Developer (Global)](vscode://your-publisher-name.awesome-copilot-ghe/install?type=instruction&link=instructions/ha-mobile-developer.instructions.md&target=global)

### Instructions (View Only)

- [View Jest Best Practices](vscode://your-publisher-name.awesome-copilot-ghe/install?type=instruction&link=instructions/jest-best-practices.instructions.md&target=view)
- [View Spring Boot Best Practices](vscode://your-publisher-name.awesome-copilot-ghe/install?type=instruction&link=instructions/spring-boot-best-practices.instructions.md&target=view)

### Prompts

- [Install Architecture Blueprint Generator](vscode://your-publisher-name.awesome-copilot-ghe/install?type=prompt&link=prompts/architecture-blueprint-generator.prompt.md&target=ask)
- [Install Professional Prompt Builder](vscode://your-publisher-name.awesome-copilot-ghe/install?type=prompt&link=prompts/professional-prompt-builder.md&target=global)

### Chat Modes / Agents

- [Install DHPAI Copilot Booster](vscode://your-publisher-name.awesome-copilot-ghe/install?type=chatmode&link=chatmodes/cms-dhpai-copilot-booster-doc.chatmode.md&target=global)
- [Install SP Evaluation Agent](vscode://your-publisher-name.awesome-copilot-ghe/install?type=chatmode&link=chatmodes/cms-dhpai-sp-evaluation-doc.chatmode.md&target=workspace)

### Collections

- [Install Demo Collection (Ask)](vscode://your-publisher-name.awesome-copilot-ghe/install?type=collection&link=collections/demo.collection.yml&target=ask)
- [View Demo Collection](vscode://your-publisher-name.awesome-copilot-ghe/install?type=collection&link=collections/demo.collection.yml&target=view)

## 🔍 How to Debug

1. **Start Debug Mode**: Press `F5` in VS Code
2. **Open This File** in the Extension Development Host window
3. **Click a Link**: Ctrl+Click (or Cmd+Click) any link above
4. **Watch Debug Console**: View → Debug Console (Ctrl+Shift+Y)
5. **Look for Logs**: You should see emoji logs like:
   ```
   🔗 Received URI: vscode://...
   📋 Install parameters: { type: 'instruction', link: '...', target: 'ask' }
   ✅ Parameters valid, starting installation...
   🔐 Checking authentication...
   ✅ Authenticated
   📥 Fetching content from: instructions/ha-java-developer.instructions.md
   ✅ Content fetched, length: 12345
   📄 Filename: ha-java-developer.instructions.md
   📦 Determining installation target...
   ...
   ```

## 🐛 Troubleshooting

### "Unknown URI path"

- Check that the link includes `/install` in the path
- Correct: `vscode://publisher.extension/install?...`
- Wrong: `vscode://publisher.extension?...`

### No Logs Appear

- Make sure you're clicking links in the **Extension Development Host** window
- Check that the extension compiled: look for `out/` directory
- Recompile: Run `npm run compile` in the extension directory

### Authentication Errors

- Make sure you have configured GitHub Enterprise credentials
- Run `Awesome Copilot: Explore and Install` command first to authenticate
- Check your settings for `awesome-copilot-ghe.baseUrl`

### Content Not Fetching

- Check Debug Console for fetch errors
- Verify the link path is correct (case-sensitive)
- Make sure you have access to the repository

### Installation Fails Silently

- Look for `❌` logs in Debug Console
- Check file permissions in target directory
- Verify workspace is open (for workspace installs)

## 📊 What You Should See

### Success Flow:

1. Click link
2. Extension activates (logs appear)
3. Parameters validated
4. Authentication check
5. Content fetched
6. Installation target chosen (if `target=ask`)
7. File installed or opened
8. Success message shown
9. File opens in editor

### If It Fails:

- Look for `❌` emoji in Debug Console
- Error message should appear
- Check the specific error message

## 💡 Tips

- Use `target=view` for quick testing (no installation, just preview)
- Use `target=ask` to see the installation dialog
- Use `target=global` or `target=workspace` for direct installation
- Check the Debug Console **after every click** for detailed logs
