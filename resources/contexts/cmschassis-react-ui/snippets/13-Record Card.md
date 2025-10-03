# Record Card

A flexible card for displaying structured record information, with support for expandable content, multiple titles, and action buttons.

---

## `<RecordCard />`

**Props:**

| Prop      | Type                | Description                                      |
|-----------|---------------------|--------------------------------------------------|
| `id`      | `string`            | Unique identifier for the card.                  |
| `title`   | `string \| string[]`| Main title or array of titles (e.g. name, type). |
| `actions` | `RecordCardAction[]`| Optional: array of action buttons (icon + handler). |
| `children`| `ReactNode`         | Main content (primary/supplementary info, etc).  |

---

## Usage Patterns

- **Default:**  
  Show a single title and main content.

- **Expandable:**  
  Add supplementary info below the main content.

- **Multiple Titles:**  
  Pass an array to `title` for multi-line or multi-field headers.

- **With Actions:**  
  Pass an `actions` array for icon buttons (e.g. print, edit, delete).

---

## Example

```tsx
<RecordCard
  id="test-id-1"
  title={["Patient Record", "Chan Tai Man", "Male"]}
  actions={[
    { iconSvg: <Print />, onClick: () => alert("print") },
    { iconSvg: <Delete />, onClick: () => alert("delete") },
    { iconSvg: <Edit />, onClick: () => alert("edit") },
  ]}
>
  {/* Primary and supplementary info here */}
</RecordCard>
```
