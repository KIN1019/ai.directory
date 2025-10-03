# Layout

Reusable flexbox-based layout primitives for horizontal and vertical stacking.

---

## `<Horizontal />`

A row flex container for arranging children side-by-side.

**Props:**

| Prop            | Type                | Description                                 |
|-----------------|---------------------|---------------------------------------------|
| `children`      | `ReactNode`         | Elements to arrange horizontally.           |
| `justifyContent`| `string`            | Flexbox justify-content (e.g. `flex-end`).  |
| `spacing`       | `"independent" \| "relatedChoices"` | Controls gap between children.    |
| `style`         | `object`            | Inline styles.                              |

**Usage:**

```tsx
<Horizontal>
  <Typography>first</Typography>
  <Typography>second</Typography>
  <Typography>third</Typography>
</Horizontal>
```

- Use `justifyContent` to align children (e.g. `flex-end`).
- Use `spacing` for semantic gaps:  
  - `"independent"`: for unrelated controls  
  - `"relatedChoices"`: for grouped options

---

## `<Vertical />`

A column flex container for stacking children vertically.

**Props:**

| Prop        | Type                | Description                                 |
|-------------|---------------------|---------------------------------------------|
| `children`  | `ReactNode`         | Elements to arrange vertically.             |
| `spacing`   | `"independent" \| "related" \| "relatedChoices"` | Controls vertical gap. |
| `divider`   | `ReactNode`         | Optional divider between children.          |
| `style`     | `object`            | Inline styles.                              |

**Usage:**

```tsx
<Vertical>
  <Typography>first</Typography>
  <Typography>second</Typography>
  <Typography>third</Typography>
</Vertical>
```

- Use `divider` to insert a visual separator (e.g. `<Divider />`).
- Use `spacing` for semantic vertical gaps:
  - `"independent"`: between unrelated blocks
  - `"related"`: between related label/field
  - `"relatedChoices"`: between grouped options

---

## Spacing Patterns

- Combine `Horizontal` and `Vertical` for complex layouts.
- Use semantic `spacing` values for consistent UI rhythm.
- Example:  
  - `Horizontal spacing="independent"` for button groups  
  - `Vertical spacing="related"` for label + field  
  - `Vertical spacing="relatedChoices"` for checkbox/radio groups

