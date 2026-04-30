# 🔗 GitHub Pages Redirect Service Setup

This directory contains a simple redirect service for converting HTTPS links to `vscode://` protocol links.

## 📋 What This Does

When users click installation links in your documentation:

1. They're redirected to an HTTPS URL (e.g., `https://yourusername.github.io/your-repo/redirect?url=...`)
2. The redirect page automatically opens VS Code with the installation link
3. If VS Code doesn't open, users can copy the link manually

## 🚀 Setup Instructions

### Step 1: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under **Source**, select:
   - Branch: `main` (or your default branch)
   - Folder: `/ (root)`
4. Click **Save**
5. Wait a few minutes for GitHub Pages to deploy
6. GitHub will show you the URL where your site is published (e.g., `https://yourusername.github.io/your-repo/`)

### Step 2: Test Your Redirect Page

After GitHub Pages is enabled, your redirect page will be available at:

```
https://YOUR-USERNAME.github.io/YOUR-REPO/redirect/
```

**Test it** by visiting:

```
https://YOUR-USERNAME.github.io/YOUR-REPO/redirect/?url=vscode://dhpai.dhpai/install?type=instruction&link=test.md&target=ask
```

This should open VS Code (if installed) or show you a link to copy.

### Step 3: Update Documentation Generator Config

Edit `scripts/generate-docs.js` and update the redirect service configuration:

```javascript
redirectService: {
    enabled: true,
    baseUrl: 'https://YOUR-USERNAME.github.io/YOUR-REPO/redirect',
}
```

Replace:

- `YOUR-USERNAME` with your GitHub username or organization
- `YOUR-REPO` with your repository name

### Step 4: Regenerate Documentation

Run the documentation generator:

```bash
npm run generate:docs
```

This will generate new documentation files with HTTPS redirect links that work everywhere!

## 📝 Example Links

After setup, your links will look like:

```
https://YOUR-USERNAME.github.io/YOUR-REPO/redirect/?url=vscode%3A%2F%2Fdhpai.dhpai%2Finstall%3Ftype%3Dinstruction%26link%3Dinstructions%2Fjava.instructions.md%26target%3Dask
```

When clicked:

1. ✅ Opens in any browser
2. ✅ Works on GitHub web interface
3. ✅ No protocol blocking issues
4. ✅ Automatically redirects to VS Code

## 🎨 Customization

### Change Colors

Edit `redirect/index.html` and modify the CSS gradient:

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

### Change Logo

Replace the emoji in the HTML:

```html
<div class="logo">📦</div>
```

### Add Branding

Add your logo or company name to the redirect page for better branding.

## 🔧 Alternative: Use Subdomain

If you want cleaner URLs, you can:

1. Set up a custom domain in GitHub Pages settings
2. Use something like `install.your-domain.com`
3. Update the `baseUrl` in config:

```javascript
redirectService: {
    enabled: true,
    baseUrl: 'https://install.your-domain.com',
}
```

## ✅ Benefits of This Approach

- ✅ **Free**: No hosting costs
- ✅ **Fast**: GitHub's CDN
- ✅ **Reliable**: 99.9% uptime
- ✅ **Works everywhere**: HTTPS links aren't blocked
- ✅ **No servers**: Static HTML only
- ✅ **Easy to maintain**: Single HTML file

## 🐛 Troubleshooting

### Redirect page shows 404

- Make sure GitHub Pages is enabled in repository settings
- Verify the `redirect` directory is committed to your repository
- Check that you're using the correct URL path

### VS Code doesn't open

- This is normal browser security behavior
- The fallback UI will show users how to copy the link
- Users can paste it into their browser address bar

### Links don't work on mobile

- `vscode://` protocol only works on desktop
- Users need VS Code installed on their machine

## 📚 Further Reading

- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Custom Domains for GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)

---

**Need Help?** Check the main README or open an issue in this repository.
