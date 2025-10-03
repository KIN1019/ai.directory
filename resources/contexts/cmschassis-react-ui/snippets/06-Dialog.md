# `<Dialog />`

A modal dialog component for confirmations, forms, and informative content.

---

## Props

| Prop         | Type      | Description                                                                 |
|--------------|-----------|-----------------------------------------------------------------------------|
| `open`       | `boolean` | Controls dialog visibility.                                                 |
| `onClose`    | `(event, reason) => void` | Called when dialog requests to close (backdrop, escape, X, etc).      |
| `title`      | `string`  | Dialog title.                                                               |
| `maxWidth`   | `string`  | Dialog width (`sm`, `md`, `lg`, etc).                                       |
| `closable`   | `boolean` | If true, dialog can be closed by backdrop, escape, or X button.             |
| `noPadding`  | `boolean` | Removes default content padding.                                            |
| `actions`    | `ReactNode` | Action bar (usually `<DialogActionBar>` with buttons).                    |
| `TransitionProps` | `object` | Props for transition (e.g. focus management on open).                   |

---

## Usage Patterns

### Default (Non-closable)

- By default, `closable` is `false`:
  - Cannot close by clicking backdrop, pressing Escape, or X button.
  - Must close via your own action (e.g. OK/Cancel button).

```tsx
<Dialog
  open={open}
  title="Default"
  onClose={handleClose}
  actions={
    <DialogActionBar>
      <Button onClick={onClickCancel}>Cancel</Button>
      <Button onClick={onClickOk}>OK</Button>
    </DialogActionBar>
  }
>
  {/* Content */}
</Dialog>
```

### Closable

- Set `closable={true}` to allow closing by:
  - Backdrop click
  - Escape key
  - X button

### Informative Dialog

- Use `DialogActionBar variant="informative"` for special styling.
- Can embed complex content (e.g. `<DataTable />`) inside dialog.

### No Padding

- Set `noPadding={true}` to remove default content padding (for custom layouts).

---

## Utilities

- `useButtonFocus()`: Utility hook to focus a button when dialog opens (for accessibility).

---

## Example

```tsx
const { triggerFocus, btnActionRef } = useButtonFocus();
<Dialog
  open={open}
  title="Closable Dialog"
  closable
  maxWidth="md"
  onClose={handleClose}
  TransitionProps={{ onEntered: triggerFocus }}
  actions={
    <DialogActionBar>
      <Button onClick={onClickCancel}>Cancel</Button>
      <Button onClick={onClickOk} action={btnActionRef}>OK</Button>
    </DialogActionBar>
  }
>
  <Typography>Dialog content here.</Typography>
</Dialog>
```
