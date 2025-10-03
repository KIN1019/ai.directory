# Loading Spinner

Visual indicator for loading states, with indeterminate, determinate, contextual, and overlay modes.

---

## `<LoadingSpinner />`

**Props:**

| Prop           | Type                                 | Description                                 |
|----------------|--------------------------------------|---------------------------------------------|
| `size`         | `"small" \| "medium" \| "large"`     | Spinner size.                               |
| `variant`      | `"indeterminate" \| "determinate"`   | Spinner mode.                               |
| `value`        | `number`                             | Progress value (for `determinate` only).    |
| `label`        | `string`                             | Optional label text.                        |
| `labelPosition`| `"right" \| "left" \| "top" \| "bottom"` | Label placement.                        |

**Usage:**

- **Indeterminate:** For unknown duration.
  ```tsx
  <LoadingSpinner size="medium" variant="indeterminate" />
  ```
- **Determinate:** For known progress.
  ```tsx
  <LoadingSpinner size="medium" variant="determinate" value={progress} />
  ```
- **Contextual:** With label, e.g. `"Updating"`, and custom label position.

---

## `<LoadingSpinnerOverlay />`

Full-screen or container overlay for blocking UI during loading.

**Props:**

| Prop   | Type      | Description                      |
|--------|-----------|----------------------------------|
| `open` | `boolean` | Show/hide the overlay.           |
| `children` | `ReactNode` | Spinner and optional content. |

**Usage:**

```tsx
<LoadingSpinnerOverlay open={open}>
  <LoadingSpinner size="medium" variant="indeterminate" />
</LoadingSpinnerOverlay>
```

---

## Patterns

- Use `LoadingSpinner` for inline or contextual loading.
- Use `LoadingSpinnerOverlay` to block UI during async operations.
- Combine with buttons or actions to indicate progress and completion.
