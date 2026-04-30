# Build Instructions

This document provides step-by-step instructions for building and packaging the Awesome Copilot extension.

## Prerequisites

Before building, ensure you have:

1. **Node.js** (version 20 or higher)
   - Download from: https://nodejs.org/
   - Verify: `node --version`

2. **npm** (comes with Node.js)
   - Verify: `npm --version`

3. **Git**
   - Download from: https://git-scm.com/
   - Verify: `git --version`

## Setup Development Environment

### 1. Clone the Repository

```bash
git clone https://hagithub.home/CMS/cms-dhpai-copilot-template.git
cd cms-dhpai-copilot-template/extension
```

### 2. Install Dependencies

```bash
npm install
```

This will install all required dependencies including:

- TypeScript compiler
- VS Code type definitions
- ESLint and TypeScript ESLint
- VSCE (VS Code Extension packager)

### 3. Compile TypeScript

```bash
npm run compile
```

Or for continuous compilation during development:

```bash
npm run watch
```

## Development

### Running the Extension

1. Open the `extension` folder in VS Code:

   ```bash
   code .
   ```

2. Press `F5` to launch the Extension Development Host
   - This opens a new VS Code window with the extension loaded
   - You can set breakpoints and debug TypeScript code

3. Test the extension:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Type "Awesome Copilot"
   - Select a command to test

### Code Quality

#### Linting

Check for code quality issues:

```bash
npm run lint
```

Fix auto-fixable issues:

```bash
npx eslint src --ext ts --fix
```

#### Type Checking

TypeScript type checking happens automatically during compilation. To check without emitting files:

```bash
npx tsc --noEmit
```

## Building for Distribution

### 1. Prepare for Build

Ensure all code is compiled and linted:

```bash
npm run vscode:prepublish
```

This command:

- Compiles TypeScript to JavaScript
- Optimizes the output
- Prepares the extension for packaging

### 2. Package the Extension

#### Option A: Using npm script

```bash
npm run package
```

#### Option B: Using vsce directly

```bash
npx vsce package
```

#### Option C: With specific version

```bash
npx vsce package --out awesome-copilot-ghe-v1.0.0.vsix
```

### 3. Verify the Package

After building, you'll see a `.vsix` file in the extension directory:

```
awesome-copilot-ghe-1.0.0.vsix
```

To inspect the contents:

```bash
# On Linux/Mac
unzip -l awesome-copilot-ghe-1.0.0.vsix

# On Windows (PowerShell)
Expand-Archive -Path awesome-copilot-ghe-1.0.0.vsix -DestinationPath temp-vsix -Force
```

## Testing the Built Extension

### Install Locally

1. In VS Code, open Extensions view (`Ctrl+Shift+X`)
2. Click the `...` menu at the top
3. Select "Install from VSIX..."
4. Choose the `.vsix` file you built
5. Reload VS Code

### Test Installation

1. Open Command Palette
2. Run: `Awesome Copilot: Explore and Install`
3. Verify authentication works
4. Test browsing and installing items

## Publishing

### To Organization's Private Marketplace

If your organization has a private VS Code marketplace:

```bash
npx vsce publish
```

You'll need:

- Publisher credentials
- Marketplace URL configured
- Proper permissions

### Manual Distribution

1. Upload the `.vsix` file to your organization's file share or repository
2. Users can install it using "Install from VSIX..." in VS Code

## Versioning

### Update Version

Edit `package.json`:

```json
{
	"version": "1.0.1"
}
```

Or use npm:

```bash
npm version patch  # 1.0.0 -> 1.0.1
npm version minor  # 1.0.0 -> 1.1.0
npm version major  # 1.0.0 -> 2.0.0
```

### Update Changelog

Update `CHANGELOG.md` with new features, fixes, and changes.

## Continuous Integration

### GitHub Actions Example

Create `.github/workflows/build.yml`:

```yaml
name: Build Extension

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: "20"

      - name: Install dependencies
        working-directory: ./extension
        run: npm ci

      - name: Lint
        working-directory: ./extension
        run: npm run lint

      - name: Compile
        working-directory: ./extension
        run: npm run compile

      - name: Package
        working-directory: ./extension
        run: npm run package

      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: vsix
          path: extension/*.vsix
```

## Troubleshooting

### Build Errors

**Error: Cannot find module**

```bash
rm -rf node_modules package-lock.json
npm install
```

**Error: TypeScript compilation errors**

- Check for type errors in the code
- Ensure all dependencies are installed
- Run `npm run compile` to see detailed errors

**Error: VSCE packaging fails**

- Ensure `vscode:prepublish` runs successfully
- Check that `out/` directory contains compiled JavaScript
- Verify `package.json` is valid

### Common Issues

1. **Missing dependencies**: Run `npm install`
2. **Outdated TypeScript**: Update with `npm update typescript`
3. **Permission errors**: Run with appropriate permissions or use `sudo` (Linux/Mac)

## Clean Build

To start fresh:

```bash
# Remove compiled output
rm -rf out/

# Remove node_modules
rm -rf node_modules/

# Remove package-lock.json
rm package-lock.json

# Reinstall and rebuild
npm install
npm run compile
```

## Directory Structure

```
extension/
├── src/                  # TypeScript source files
│   ├── extension.ts     # Main entry point
│   ├── auth.ts          # Authentication service
│   ├── fetcher.ts       # Content fetching
│   ├── pickers.ts       # UI pickers
│   ├── installer.ts     # Installation logic
│   ├── collections.ts   # Collection handling
│   ├── preferences.ts   # Preferences management
│   └── types.ts         # TypeScript types
├── out/                 # Compiled JavaScript (generated)
├── node_modules/        # Dependencies (generated)
├── .vscode/            # VS Code configuration
├── package.json        # Extension manifest
├── tsconfig.json       # TypeScript configuration
└── README.md           # Documentation
```

## Additional Resources

- [VS Code Extension API](https://code.visualstudio.com/api)
- [Publishing Extensions](https://code.visualstudio.com/api/working-with-extensions/publishing-extension)
- [Extension Manifest](https://code.visualstudio.com/api/references/extension-manifest)
