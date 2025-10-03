# Alert Box

A simple, styled container for alerting users to errors or important messages.

---

## `<AlertBox />`

**Props:**

| Prop     | Type        | Description                |
|----------|-------------|----------------------------|
| `id`     | `string`    | Unique identifier.         |
| `title`  | `string`    | Alert title.               |
| `children` | `ReactNode` | Alert content (text or custom nodes). |

---

## Usage Patterns

- **Basic:**  
  Show a title and a message.

  ```tsx
  <AlertBox id="" title="Error(s) found in the form">
    Please check and try again
  </AlertBox>
  ```

- **Custom Content:**  
  Pass any React nodes (e.g. a list of errors) as children.

  ```tsx
  <AlertBox id="" title="Error(s) found in the form">
    <List>
      <ListItem>First error</ListItem>
      <ListItem>Second error</ListItem>
      <ListItem>Third error</ListItem>
    </List>
  </AlertBox>
  ```
