# Text Area

A multi-line text input with validation, counter, and ref support.

---

## `<TextArea />`

**Props:**

| Prop         | Type                                | Description                                 |
|--------------|-------------------------------------|---------------------------------------------|
| `value`      | `string`                            | Current value.                              |
| `onChange`   | `(newValue: string) => void`        | Change handler.                             |
| `size`       | `"small" \| "medium" \| "large"`    | Input size.                                 |
| `label`      | `string`                            | Field label.                                |
| `helperText` | `string`                            | Helper text below the field.                |
| `error`      | `boolean`                           | Error state.                                |
| `disabled`   | `boolean`                           | Disabled state.                             |
| `fullWidth`  | `boolean`                           | Stretch to fill container.                  |
| `row`        | `number`                            | Number of visible rows.                     |
| `counter`    | `{ count: number, threshold: number }` | Show character count and limit.         |
| `inputRef`   | `React.Ref<HTMLInputElement>`       | Ref for programmatic focus.                 |
| `onKeyUp`/`onKeyDown`/`onBlur` | `(event) => void` | Keyboard and blur event handlers.           |

---

## Usage Patterns

- **Minimal:**  
  Basic multi-line input with value and change handler.

- **Validation:**  
  Add `label`, `helperText`, `error`, and `disabled` for form feedback.

- **Show Counter:**  
  Use `counter` prop to display character count and enforce a limit.

- **Input Ref:**  
  Use `inputRef` to programmatically focus the input.

---

## Example

```tsx
<TextArea
  value={value}
  onChange={setValue}
  size="medium"
  label="Details"
  helperText="Please provide further details."
  error={hasError}
  fullWidth
  row={3}
  counter={{ count: value.length, threshold: 500 }}
  inputRef={inputRef}
  onKeyUp={handleKeyUp}
  onKeyDown={handleKeyDown}
  onBlur={handleBlur}
/>
```
