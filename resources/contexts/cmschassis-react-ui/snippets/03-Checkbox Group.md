# Checkbox Group

A flexible group of checkboxes for string or object options, with custom rendering and layout.

---

## `<CheckboxGroup />`

**Props:**

| Prop           | Type                | Description                                      |
|----------------|---------------------|--------------------------------------------------|
| `value`        | `string[]`          | Selected values.                                 |
| `onChange`     | `(newValue: string[]) => void` | Change handler.                    |
| `options`      | `string[] \| object[]` | List of options (strings or objects).         |
| `optionValue`  | `(option) => string` | Extracts value from option.                      |
| `renderOption` | `(option) => ReactNode` | Renders label for each option.                |
| `onOptionChange` | `(newOptions: object[]) => void` | (Object mode) callback for changed options. |
| `direction`    | `"row" \| "column"` | Layout direction.                                |
| `label`        | `string`            | Group label.                                     |
| `helperText`   | `string`            | Helper text below group.                         |
| `nestedLabel`  | `string`            | Label for "Select All" option.                   |
| `disabled`     | `boolean`           | Disable all checkboxes.                          |
| `error`        | `boolean`           | Error state.                                     |
| `size`         | `"small" \| "medium" \| "large"` | Checkbox size.                          |

---

## Usage Patterns

- **String options:**  
  Pass an array of strings, and use `optionValue`/`renderOption` for value/label.

- **Object options:**  
  Pass an array of objects, and use `optionValue`/`renderOption` for value/label.  
  Use `onOptionChange` to get the changed option objects.

- **Custom layout:**  
  Use `direction="row"` or `direction="column"`, and add `label`, `helperText`, or `nestedLabel` as needed.

- **Custom rendering:**  
  Use `renderOption` to customize label appearance (e.g. with `<Typography>` and custom styles).

---

## Example

```tsx
<CheckboxGroup
  value={selected}
  onChange={setSelected}
  options={[{ val: "QMH", display: "Queen Mary Hospital" }]}
  optionValue={option => option.val}
  renderOption={option => <Typography>{option.display}</Typography>}
  direction="column"
  label="Hospital"
  helperText="Please select preferred hospitals."
  nestedLabel="Select All"
  size="medium"
/>
```
