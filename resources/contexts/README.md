# Contexts Directory

Development contexts with project guidelines, standards, and code snippets. These appear in the `/contexts` section of the website.

## Format

Each context is a directory containing:

**`_meta.yaml`** - Context metadata:

```yaml
name: Context Name
description: Brief description of the context
slug: context-slug
source: /repository/path # optional
lastUpdated: 2024-01-15 # optional
techStacks:
  - react
  - typescript
teams:
  - cp14
  - core-platform
categories:
  - website
  - dashboard
```

**`README.md`** - Main context documentation with guidelines and standards

**`snippets/`** - Directory containing code snippet files:

- `snippet-name.md` - Individual code examples and patterns

**Website display:**

- `name` → Card title and individual page heading
- `description` → Card description text in listings
- `techStacks` → Technology filter badges
- `teams` → Team filter badges
- `categories` → Category filter badges
- `README.md` → Main content when clicked
- `snippets/` → Available code snippets list

**Tags:** Must exist in `tags.yaml` under respective sections or error will be thrown. Add new tags there first:

```yaml
techStacks:
  - slug: new-tech
    name: Display Name
teams:
  - slug: new-team
    name: Team Name
categories:
  - slug: new-category
    name: Category Name
```

**Directory naming:** Use kebab-case like `ha-frontend-context/`
