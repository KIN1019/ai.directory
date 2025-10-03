# Text Field

A single-line text input with validation, adornments, and ref support.

---

## `<TextField />`

**Props:**

| Prop                | Type                                | Description                                 |
|---------------------|-------------------------------------|---------------------------------------------|
| `value`             | `string`                            | Current value.                              |
| `onChange`          | `(newValue: string) => void`        | Change handler.                             |
| `size`              | `"small" \| "medium" \| "large"`    | Input size.                                 |
| `label`             | `string`                            | Field label.                                |
| `helperText`        | `string`                            | Helper text below the field.                |
| `error`             | `boolean`                           | Error state.                                |
| `disabled`          | `boolean`                           | Disabled state.                             |
| `fullWidth`         | `boolean`                           | Stretch to fill container.                  |
| `placeholder`       | `string`                            | Placeholder text.                           |
| `leadingIcon`       | `ReactNode`                         | Icon at the start of the field.             |
| `trailingIcon`      | `ReactNode`                         | Icon at the end of the field.               |
| `endAdornmentOnClick` | `() => void`                      | Handler for clicking trailing icon.          |
| `inputRef`          | `React.Ref<HTMLInputElement>`       | Ref for programmatic focus.                 |
| `onKeyUp`/`onKeyDown`/`onBlur` | `(event) => void`        | Keyboard and blur event handlers.           |

---

## Usage Patterns

- **Customized:**  
  Use icons, adornment click, and all validation/label props.

- **As Display:**  
  Omit `onChange` to make the field read-only.

- **Input Ref:**  
  Use `inputRef` to programmatically focus the input.

---

## Example

```tsx
<TextField
  value={value}
  onChange={setValue}
  size="medium"
  label="Details"
  helperText="Please provide further details."
  error={hasError}
  fullWidth
  placeholder="Type here"
  leadingIcon={<Detail />}
  trailingIcon={<Cancel />}
  endAdornmentOnClick={clearValue}
  inputRef={inputRef}
  onKeyUp={handleKeyUp}
  onKeyDown={handleKeyDown}
  onBlur={handleBlur}
/>
```
