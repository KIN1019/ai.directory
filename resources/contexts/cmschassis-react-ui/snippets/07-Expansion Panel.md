# `<ExpansionPanel />`

A scrollable, titled container for expandable content—ideal for displaying lists of cards or records.

---

## Props

| Prop      | Type                      | Description                        |
|-----------|---------------------------|------------------------------------|
| `id`      | `string`                  | Unique identifier for the panel.   |
| `title`   | `string`                  | Panel header/title.                |
| `size`    | `"small" \| "medium" \| "large"` | Controls panel sizing.      |
| `children`| `ReactNode`               | Content to display inside panel.   |

---

## Usage

- Place any content (e.g. a list of `<RecordCard />`s) inside the panel.
- Commonly used for displaying patient or record summaries with actions.

```tsx
<ExpansionPanel id="test-id-01" title="Patient Record" size="medium">
  {Array.from({ length: 100 }).map((_, i) => (
    <RecordCard
      key={i}
      title={[`Patient Record ${i}`, "Chan Tai Man", "Male"]}
      id="test-id-1"
      actions={[
        { iconSvg: <Print />, onClick: () => alert("print") },
        { iconSvg: <Delete />, onClick: () => alert("delete") },
        { iconSvg: <Edit />, onClick: () => alert("edit") },
      ]}
    >
      {/* Primary and supplementary info here */}
    </RecordCard>
  ))}
</ExpansionPanel>
```

---

## Typical Pattern

- Use with `<RecordCard />` for structured, actionable content.
- Supports custom action icons and click handlers for each card.
- Panel is scrollable if content overflows.

---

## Example Layout

- Place inside a container with fixed width/height for scrollable area.
- Example: patient record summary, management plan, admission/discharge info, etc.
