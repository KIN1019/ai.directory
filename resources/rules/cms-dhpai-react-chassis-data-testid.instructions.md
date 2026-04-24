---
title: CMS DHPAI React Chassis Data TestID Instructions
description: Instructions for adding `data-testid` attributes to the React Chassis codebase for automated test reliability. Focuses on forms, dialogs, tables, buttons, and inputs. Go to https://hagithub.home/CMS/cms-dhpai-react-chassis-data-testid-doc for more details.
tags: [dhpai, react, testing, data-testid, frontend]
---

**"I need to add `data-testid` attributes to our entire React codebase for automated test reliability. This is a large task, so I want to be strategic about it.

**Current State:**
- React + MUI application with many `.tsx` files in src
- Many components lack `data-testid` attributes
- High-value files to prioritize: forms, dialogs, tables, buttons, inputs (things testers interact with)
  
**Task Approach (in phases):**
1. **Scan & Plan** (Phase 1):
   - Find all `.tsx` files in src with interactable elements (imports MUI components, @cmschassis/react-ui, has onClick/onChange handlers)
   - For each file, identify all interactable elements, including:
  **MUI Components**: `<Button>`, `<IconButton>`, `<Fab>`, `<LoadingButton>`, `<TextField>`, `<Autocomplete>`, `<Select>`, `<Slider>`, `<Switch>`, `<Checkbox>`, `<Radio>`, `<RadioGroup>`, `<FormControl>`, `<FormGroup>`, `<Link>`, `<MenuItem>`, `<Tab>`, `<PaginationItem>`, clickable `<ListItem>`, `<Dialog>` buttons (e.g., close, confirm), `<Modal>` buttons.
  **Native HTML**: `<button>`, `<input>`, `<select>`, `<textarea>`, `<a>` with `onClick`, or any element with event handlers (`onClick`, `onChange`, `onSubmit`, etc.).
  **Custom Components**: Any custom React component that renders interactable UI or has event handlers, this is the most challenging part. You should find all components that render mui component under the hood and pass the data-testid hierarchically, e.g. `<ControlledComboBox>`, `<ControlledTextField>`, `<ControlledCheckbox>`, `<ControlledSwitch>`, `<ControlledDatePicker>`, `<ControlledSingleSelect>`, `<ControlledFormTextView>`, `<ControlledFileInputField>`.
  **Dynamic Elements**: Elements in lists, tables, or loops (e.g., `<TableRow>`, `<ListItem>` with `onClick`).
   - Categorize them by priority: CRITICAL (forms, dialogs, auth), HIGH (tables, lists, navigation), MEDIUM (utility components)
   - Draft a CSV showing: filename | file path | component count | estimated testId count | priority
1. **Implement in Batches** (Phase 2):
   - Start with CRITICAL category: forms, dialogs, modals
   - Use naming convention: `[page/feature]-[component-type]-[action/purpose]`
   - Dynamic elements: `[identifier]-row-${index}` or `[identifier]-item-${id}`
   - For each file: add testIds → verify TypeScript compilation → move to next
2. **Extend & Validate** (Phase 3):
   - Extend to HIGH category files
   - After all implementation: grep search for any remaining gaps
   - Verify no "undefined-" or empty testIds

**Constraints:**
- Do NOT modify existing `data-testid` attributes
- Do NOT alter functionality, styles, or accessibility
- Maintain TypeScript type safety
- Skip files that already have 100% testId coverage
- If you need to create deterministic script for scan, using javascript / node
  
**Success Criteria:**
- CRITICAL files: 95%+ testId coverage
- HIGH files: 80%+ testId coverage
- Zero TypeScript errors
- No regressions in existing tests
- CSV report showing before/after coverage
