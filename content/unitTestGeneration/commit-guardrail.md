# Commit Message Hook Setup

This guide explains how to set up a Git commit hook that enforces strict file modification rules when using the `test:` commit prefix.

## Overview

The `commit-msg` hook ensures that if a commit message starts with `test:`, only files in specific allowed directories (e.g., `tests/`, configuration files) are included in the commit. This prevents accidental changes to source code when intending to only update tests.

## Installation

### 1. Create the Hook File

Create a file named `commit-msg` (without any extension) inside a `.githooks` directory in your project root:

**.githooks/commit-msg**
```sh
#!/bin/sh

# ---------------------------------------------------
# CONFIGURATION: Define allowed directories/files (Regex format)
# Modify this pattern to match your allowed files
# Example: ^(tests/|docs/|package\.json) matches files in tests/, docs/, or package.json
# ---------------------------------------------------
ALLOWED_PATTERN="^(tests/|vitest\.config\.ts|package\.json)"

# 1. Read the commit message from the temp file provided by Git
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# 2. Check if message starts with "test:"
if echo "$COMMIT_MSG" | grep -qE "^test:"; then

    # 3. Get staged files
    # Note: We check staged files because the commit hasn't happened yet
    STAGED_FILES=$(git diff --cached --name-only)

    # Find files that DO NOT match the allowed pattern
    FORBIDDEN_FILES=$(echo "$STAGED_FILES" | grep -vE "$ALLOWED_PATTERN")

    if [ -n "$FORBIDDEN_FILES" ]; then
        echo "❌ COMMIT REJECTED"
        echo "Commit message starts with 'test:', but the following files are not in the allowed list:"
        echo "--------------------------------------------------"
        echo "$FORBIDDEN_FILES"
        echo "--------------------------------------------------"
        echo "Aborting commit."
        exit 1
    fi
fi

exit 0
```

### 2. Configure Git Hooks Path

Run the following command in your terminal to tell Git to use the `.githooks` directory for hooks instead of the default `.git/hooks`:

```bash
git config --local core.hooksPath .githooks
```

**Note:** We use a custom `.githooks/` directory because the standard `.git/hooks/` directory is not version-controlled. This approach ensures every developer on the team shares the same hooks.

### 3. Make Executable (Mac/Linux only)

If you are on macOS or Linux, you must make the script executable:

```bash
chmod +x .githooks/commit-msg
```

## Configuration

To change which files are allowed for `test:` commits, edit the `ALLOWED_PATTERN` variable in `.githooks/commit-msg`.

The pattern uses Regular Expressions.
*   **Example**: Allow `tests` folder and `package.json`
    ```bash
    ALLOWED_PATTERN="^(tests/|package\.json)"
    ```

## Verification

To test that the hook is working correctly:

1.  **Pass Case**: Change a file in `tests/` and commit with `test: update tests`.
    *   *Result*: Commit succeeds.
2.  **Fail Case**: Change a file in `src/` (or any non-allowed folder) and commit with `test: change code`.
    *   *Result*: Commit fails with a rejection message.
