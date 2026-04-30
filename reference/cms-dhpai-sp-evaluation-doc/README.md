# Stored Procedure Migration Analysis with GitHub Copilot

This guide explains how to use GitHub Copilot to perform a quality assurance check on stored procedures migrated from Sybase ASE to PostgreSQL.

> The instructions in `.github/copilot-instructions.md` are optimized for Claude 4. For best results, using the **Claude 4 Sonnet** model is recommended.

**Verification Required: All code generated should be thoroughly reviewed and tested before implementation. The AI may not account for specific project requirements or environments.**

## Quick Start

1.  **Provide Context**: Give GitHub Copilot the `.github/copilot-instructions.md` file.
2.  **Give Instruction**: Tell it to start analyzing the SQL files (e.g., "Start analyzing stored procedures in `sp/postgresql`").
3.  **Monitor Progress**: GitHub Copilot will track its progress in `copilot-states.md` and log issues in `summary.tsv`. You can view these files to see the live status.
4.  **Review**: Check the `.sql` files for comments added by Copilot.

## How It Works

GitHub Copilot, acting as a **Senior Database Migration Engineer**, finds errors in SQL files migrated from Sybase to PostgreSQL. It documents findings directly in the SQL files and in summary reports.

## Output Guide

- **In-File Comments**:
  - `-- ! The conversion error`: A critical issue that must be fixed.
  - `-- ? this is a best practice improvement`: A non-critical recommendation.

  > The `!` and `?` prefixes in the comments are designed for use with the [Better Comments](https://marketplace.cursorapi.com/items/?itemName=aaron-bond.better-comments) VS Code extension. Please install it to see these comments highlighted in your editor for improved visibility.

- **Progress Tracker (`copilot-states.md`)**: Automatically updated by Copilot to show the high-level status of which files have been analyzed.
- **Issues Summary (`summary.tsv`)**: Automatically updated by Copilot with a detailed, machine-readable log of every issue found. Key columns include `filename`, `risk`, `line_number`, `error_snippet`, `description`, `suggested_fix`, and `impact`.

### `summary.tsv` Column Descriptions

| Column          | Description                                                                                                                                                                   |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `filename`      | The path to the SQL file where the issue was found.                                                                                                                           |
| `file_size`     | The size of the file, retrieved using a command like `ls -lh`.                                                                                                                |
| `risk`          | The assessed risk level: **HIGH** (potential data loss/corruption, system failure), **MEDIUM** (incorrect results, performance issues), or **LOW** (cosmetic, best practice). |
| `issue`         | A brief, standardized category for the error type (e.g., "NULL Comparison," "Cursor Operation," "Legacy Join").                                                               |
| `line_number`   | The exact line number of the problematic code, found using `grep -n`.                                                                                                         |
| `error_snippet` | The exact code from the specified `line_number` that is causing the issue.                                                                                                    |
| `description`   | A clear explanation of _why_ the snippet is an issue in PostgreSQL and what its consequences are.                                                                             |
| `suggested_fix` | The corrected or recommended PostgreSQL-compliant code to resolve the issue.                                                                                                  |
| `impact`        | A summary of the potential business or operational impact if the issue is not fixed (e.g., "Procedure returns no data silently").                                             |

## Utility Scripts

The `scripts/` directory contains helpful utilities for managing this project.

- **`scripts/count_token.py`**:
  - **Purpose**: This script recursively counts the number of tokens in all `.sql` files within a specified directory. It's useful for understanding the scope of the migration and estimating the workload.
  - **Output**: It generates a CSV file (`output/token_count.csv`) with the token count for each file and a histogram (`output/token_count.png`) visualizing the token distribution.
  - **Usage**:
    ```bash
    uv run -m scripts/count_token <directory_to_scan>
    ```
  - **Example**:
    ```bash
    uv run -m scripts/count_token sp/postgresql
    ```

## Customizing the Instructions

The behavior of GitHub Copilot is controlled by the `.github/copilot-instructions.md` file. You can modify this file to change the analysis focus, output format, or risk assessment criteria.

> For more advanced prompt engineering techniques or to learn about general best practices for writing prompts, refer to Anthropic's official [Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview).

### Key Sections in the Instruction File

- **Persona & Context**:
  - Defines the role Copilot should assume (e.g., `Senior Database Migration Engineer`).
  - Provides background on the tech stack, team values, and the overall goal. You can add specific version numbers or architectural details here.

- **Reference Document (`<documents>`)**:
  - Contains the technical migration guide (`sybase-postgresql-migration-guide.md`).
  - To add new conversion rules or update existing ones, modify the content within the `<document_content>` tags. For example, you could add new function mappings or data type conversions.

- **Core Analysis Requirements (`<instructions>`)**:
  - **Risk Assessment**: You can change the definitions of HIGH, MEDIUM, and LOW risk to match your project's priorities.
  - **Documentation**: Modify the comment block format (e.g., change `-- !` to `/* CRITICAL */`) or the rules for what gets commented.
  - **State Management & Summary**: Adjust the expected format or content of `copilot-states.md` and `summary.tsv`.
  - **Specific Issues to Focus On**: This is a critical list that directs Copilot's attention. Add or remove items here to guide the analysis (e.g., add "performance optimizations" or remove "cursor operations").

- **Examples (`<examples>`)**:
  - These strongly influence the output format.
  - To change how Copilot presents its findings, modify the content within the `<example>` blocks. For instance, you could alter the structure of the analysis report or the TSV output.

By fine-tuning these sections, you can adapt the assistant's behavior to fit different migration projects or analysis requirements.
