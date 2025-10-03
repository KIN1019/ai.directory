# Progress Stepper

A multi-step progress indicator with clickable steps, status, and style variations.

---

## `<ProgressStepper />` and `<ProgressStep />`

**Props for ProgressStepper:**

| Prop      | Type            | Description                                 |
|-----------|-----------------|---------------------------------------------|
| `steps`   | `ProgressStep[]`| Array of step objects (see below).          |
| `variant` | `"variant1" \| "variant2" \| "variant3"` | Visual style. |

**Props for ProgressStep:**

| Prop      | Type            | Description                                 |
|-----------|-----------------|---------------------------------------------|
| `label`   | `() => string`  | Step label (function for dynamic label).    |
| `status`  | `"completed" \| "current" \| "future"` | Step state.   |
| `style`   | `"active" \| "success" \| "error" \| "warning"` | Visual style. |
| `icon`    | `() => ReactNode` | Optional icon (required for variants 2 & 3). |
| `onClick` | `() => void`    | Optional click handler for step navigation. |

---

## Usage Patterns

- **Basic:**  
  Use `steps` array to control stepper state.  
  Use `onClick` on steps for direct navigation, or control with Next/Back buttons.

- **Variants:**  
  - `variant1`: Basic  
  - `variant2`/`variant3`: Require `icon` for each step

- **Step Styles:**  
  - `status`: `"completed"`, `"current"`, `"future"`
  - `style`: `"active"`, `"success"`, `"error"`, `"warning"`  
    (success/error/warning only apply to `current` or `completed` steps)

---

## Example

```tsx
const steps = [
  { label: () => "Step1", status: "current", style: "active", icon: () => <Icon /> },
  { label: () => "Step2", status: "future", style: "active", icon: () => <Icon /> },
  { label: () => "Step3", status: "future", style: "active", icon: () => <Icon /> },
];

<ProgressStepper steps={steps} variant="variant1" />
```

- Use state to update `steps` and `activeStep` for navigation.
- Use `onClick` in each step for direct step selection.

---

## Patterns

- Show progress with visual feedback for each step.
- Use with vertical or horizontal layouts.
- Combine with buttons for Next/Back navigation.
