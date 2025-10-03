# Notification

Stacked, dismissible alerts for user feedback.

---

## `<NotificationStack />` & `useNotificationStack()`

**Props:**

| Prop         | Type      | Description                                 |
|--------------|-----------|---------------------------------------------|
| `children`   | `ReactNode` | Content (usually trigger buttons).        |

**Hook:**

- `enqueue(message, severity)`: Show a notification. Returns a key.
- `close(key)`: Programmatically close a notification.

**Defaults:**

- Maximum 5 alerts at once (`maxAlerts=5`).
- Each alert auto-dismisses after 5 seconds.

---

## Usage Patterns

### Basic

```tsx
const { enqueue } = useNotificationStack();
<Button onClick={() => enqueue("Saved!", "success")}>Open</Button>
<NotificationStack />
```

### Close by API

- Store keys from `enqueue` to close specific notifications.

```tsx
const { enqueue, close } = useNotificationStack();
const key = enqueue("Saved!", "success");
close(key); // Dismiss programmatically
```

### Placement

- Place `<NotificationStack />` inside any container for local notifications.

```tsx
<div style={{ width: 500, height: 400, position: "relative" }}>
  <NotificationStack />
</div>
```
