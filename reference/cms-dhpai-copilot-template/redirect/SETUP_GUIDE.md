# 🚀 Quick Setup Guide for GitHub Pages Redirect

Follow these steps to enable HTTPS redirect links for your documentation.

## ✅ Step-by-Step Setup

### 1. Commit the Redirect Files

First, make sure the `redirect/` directory is committed to your repository:

```bash
git add redirect/
git commit -m "feat: add GitHub Pages redirect service for vscode:// links"
git push
```

### 2. Enable GitHub Pages

1. Go to your GitHub repository
2. Click **Settings** (top navigation)
3. Click **Pages** (left sidebar)
4. Under **Build and deployment**:
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/ (root)`
5. Click **Save**

### 3. Wait for Deployment

GitHub Pages will automatically build and deploy your site. This takes 1-3 minutes.

You'll see a message like:

```
Your site is live at https://YOUR-USERNAME.github.io/YOUR-REPO/
```

### 4. Test the Redirect Page

Visit your redirect page:

```
https://YOUR-USERNAME.github.io/YOUR-REPO/redirect/
```

You should see a message: "Error: No installation URL provided"

Now test with a sample URL:

```
https://YOUR-USERNAME.github.io/YOUR-REPO/redirect/?url=vscode://dhpai.dhpai/install?type=instruction&link=test.md&target=ask
```

This should try to open VS Code or show you a copy link option.

### 5. Update Documentation Generator Config

Edit `scripts/generate-docs.js`:

Find the `redirectService` configuration (around line 17):

```javascript
redirectService: {
    enabled: true,  // ← Change to true
    baseUrl: 'https://YOUR-USERNAME.github.io/YOUR-REPO/redirect',  // ← Update this
},
```

**Replace:**

- `YOUR-USERNAME` with your GitHub username or org
- `YOUR-REPO` with your repository name

**Example:**

```javascript
redirectService: {
    enabled: true,
    baseUrl: 'https://dhpai.github.io/cms-dhpai-copilot-template/redirect',
},
```

### 6. Regenerate Documentation

Run the generator:

```bash
npm run generate:docs
```

This will create new documentation files with HTTPS redirect links!

### 7. Commit and Push

```bash
git add docs/ scripts/generate-docs.js
git commit -m "docs: regenerate with GitHub Pages redirect links"
git push
```

### 8. Test Installation Links

1. Push changes to GitHub
2. View any documentation file on GitHub web (e.g., `docs/README.instructions.md`)
3. Click an "Install in VS Code" button
4. It should open VS Code and prompt for installation location!

## 🎉 You're Done!

Your installation links now work everywhere:

- ✅ GitHub web interface
- ✅ Any browser
- ✅ Markdown previewers
- ✅ Documentation websites

## 🔍 Verifying It Works

After setup, your links should look like:

```
https://YOUR-USERNAME.github.io/YOUR-REPO/redirect/?url=vscode%3A%2F%2Fdhpai.dhpai%2Finstall%3Ftype%3Dinstruction%26link%3Dinstructions%252Fjava.instructions.md%26target%3Dask
```

Click one in your browser - VS Code should open!

## ❓ Troubleshooting

**404 Error on redirect page?**

- Wait 5 minutes for GitHub Pages to fully deploy
- Check that `redirect/index.html` is in your repository
- Verify GitHub Pages is enabled in Settings

**VS Code doesn't open?**

- This is normal for first-time users
- The page will show a copy-link option
- Browser security may block protocol links

**Links still show vscode:// directly?**

- Check `redirectService.enabled` is `true`
- Verify `baseUrl` matches your GitHub Pages URL
- Run `npm run generate:docs` again

## 🆘 Need Help?

Check the full documentation in `redirect/README.md` or the main `DOCS_SETUP.md` file.
