# Tabs

A flexible tab navigation component supporting horizontal/vertical layouts, closable tabs, search/filter, overflow, and secondary tab levels.

---

## `<Tabs />`

**Props:**

| Prop           | Type                | Description                                      |
|----------------|---------------------|--------------------------------------------------|
| `tabs`         | `string[]`          | List of tab labels.                              |
| `tabSelected`  | `string`            | Currently selected tab.                          |
| `onTabSelect`  | `(tab: string) => void` | Tab selection handler.                      |
| `onTabsChange` | `(tabs: string[], tabToRemove?: string) => void` | (Closable) handler for tab list changes. |
| `orientation`  | `"horizontal" \| "vertical"` | Tab bar direction.                        |
| `closable`     | `boolean`           | Show close buttons on tabs.                      |
| `showFilter`   | `boolean`           | Show search/filter input.                        |
| `title`        | `string`            | Optional group title.                            |
| `size`         | `"small" \| "medium" \| "large"` | Tab size.                              |
| `variant`      | `"primary" \| "secondary"` | Tab style (secondary for nested tabs).     |
| `filter`       | `(query: string, tab: string) => boolean` | Custom filter logic.                  |
| `children`     | `ReactNode`         | Tab panels (one per tab).                        |

---

## Usage Patterns

- **Horizontal/Vertical:**  
  Use `orientation` to switch between horizontal and vertical layouts.

- **Closable Tabs:**  
  Set `closable` and handle `onTabsChange` to allow tab removal.

- **Search/Filter:**  
  Set `showFilter` and optionally provide a custom `filter` function.

- **Overflow Menu:**  
  Automatically enabled for horizontal tabs with many items.

- **Secondary Variant:**  
  Use `variant="secondary"` for nested tab levels (not all features supported).

- **Conditional Close/Switch:**  
  Use custom handlers to confirm or block tab closing/switching.

---

## Example

```tsx
<Tabs
  tabs={["Tab 1", "Tab 2", "Tab 3"]}
  tabSelected={selected}
  onTabSelect={setSelected}
  orientation="horizontal"
  closable
  showFilter
  title="Tab Group"
>
  <TabPanel tabValue="Tab 1" tabSelected={selected}>Content 1</TabPanel>
  <TabPanel tabValue="Tab 2" tabSelected={selected}>Content 2</TabPanel>
  <TabPanel tabValue="Tab 3" tabSelected={selected}>Content 3</TabPanel>
</Tabs>
```

---

## Notes

- **Overflow menu**: Only for horizontal tabs.
- **Secondary variant**: For sub-tabs; not all features (e.g. close, filter) are supported.
- **Custom filter**: Use `filter` prop for advanced search logic.
- **TabPanel**: Render children conditionally based on `tabSelected`.
