# cms-dhpai-react-chassis-data-testid-doc

This repository serves as the central documentation and execution plan for enhancing the automated testing reliability of the `cms-dhpai` React application by systematically implementing `data-testid` attributes.

## Overview

**Goal:** Achieve high `data-testid` coverage across the React + MUI codebase to support robust automated testing.
**Scope:** ~150-200 `.tsx` files, focusing on interactable elements (forms, dialogs, tables, buttons).

## Implementation Strategy

The project follows a phased approach to ensure stability and type safety:

### Phase 1: Scan & Plan

- Identify all interactable elements (MUI components, Native HTML, Custom Components).
- Categorize files by priority:
  - **CRITICAL**: Forms, Dialogs, Auth
  - **HIGH**: Tables, Lists, Navigation
  - **MEDIUM**: Utility components

### Phase 2: Implementation

- Systematically add `data-testid` props starting with CRITICAL files.
- **Naming Convention:** `[page/feature]-[component-type]-[action/purpose]`
- **Dynamic Elements:** `[identifier]-row-${index}`

### Phase 3: Validation

- Verify TypeScript compilation.
- Ensure no regressions in existing tests.
- specific grep searches to ensure no "undefined-" or empty IDs remain.

## Guidelines & Constraints

- **Do NOT** modify existing `data-testid` attributes.
- **Do NOT** alter functionality, styles, or accessibility.
- Maintain strict TypeScript type safety.

## Documentation

- [Detailed Implementation Instructions](.github/instructions/data-testid.instructions.md) - Full breakdown of the task, current state, and specific component targets.
