# Rules Directory

Prompt templates and rules for AI agent behaviors and coding guidelines. These appear in the `/prompts` section of the website.

## Format

```markdown
---
title: Rule Name
description: Brief description
tags: [tag1, tag2, tag3]
---

You are a [specific role] with expertise in [technologies].

## Guidelines

- Specific, actionable instructions
- Coding standards and patterns
- What to do and avoid
```

**Website display:**

- `title` → Card title and individual page heading
- `description` → Card description text in listings
- `tags` → Filter categories and tag badges
- Content → Full page content when clicked

**Tags:** Must exist in `tags.yaml` or error will be thrown. Add new tags there first:

```yaml
- slug: new-tag
  name: Display Name
```

**File naming:** Use kebab-case like `ha-frontend-developer.md`
