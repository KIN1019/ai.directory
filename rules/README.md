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

**Tags:** Must exist in `tags.yaml` or an error will be thrown. Add new tags there first:

```yaml
- slug: new-tag
  name: Display Name
```

**File naming:** Use kebab-case like `ha-frontend-developer.md`

**Content:** Start with persona definition, use bullet points, be specific and actionable.
