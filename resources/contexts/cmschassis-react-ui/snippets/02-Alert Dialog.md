# Alert Dialog

A modal dialog for critical alerts, errors, confirmations, and detailed input.

---

## `<AlertDialog />`

**Props:**

| Prop           | Type                | Description                                      |
|----------------|---------------------|--------------------------------------------------|
| `open`         | `boolean`           | Show/hide the dialog.                            |
| `size`         | `"small" \| "medium"` | Dialog size.                                   |
| `variant`      | `"error" \| "warning" \| "info" \| "success"` | Alert style. |
| `title`        | `string`            | Dialog title.                                    |
| `content`      | `string`            | Main message.                                    |
| `primaryAction`| `{ label: string, onClick: () => void }` | Main action button. |
| `otherActions` | `Array<{ label: string, onClick: () => void }>` | Additional actions. |
| `children`     | `ReactNode`         | Optional: custom content (e.g. table, form).     |

---

## Usage Patterns

- **Basic:**  
  Show a message and a single action button.

- **Detailed Error:**  
  Add custom content (e.g. table of error details) as children.

- **Detailed Input:**  
  Add form controls (e.g. `<CheckboxGroup />`, `<TextArea />`) as children for user input.

---

## Example

```tsx
<AlertDialog
  open={open}
  size="medium"
  variant="error"
  title="The setting(s) could not be found"
  content="Please refresh to retrieve the latest settings and try again"
  primaryAction={{ label: "OK", onClick: handleClose }}
/>
```

**With custom content:**

```tsx
<AlertDialog
  open={open}
  variant="warning"
  title="Delete Drug Allergy"
  content="Record will be deleted permanently"
  primaryAction={{ label: "Proceed", onClick: handleProceed }}
  otherActions={[{ label: "Cancel", onClick: handleCancel }]}
>
  <CheckboxGroup ... />
  <TextArea ... />
</AlertDialog>
```
