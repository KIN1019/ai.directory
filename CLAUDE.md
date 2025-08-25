# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Development

- `npm run dev` - Start development server with Turbopack
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

### Container Operations

- `podman buildx build --platform linux/amd64 -t artifactrepo.server.ha.org.hk:55743/int-docker-dev-cms/ai-directory:latest .` - Build container image
- `podman login artifactrepo.server.ha.org.hk:55743` - Login to artifact repository
- `podman push artifactrepo.server.ha.org.hk:55743/int-docker-dev-cms/ai-directory:latest --tls-verify=false` - Push image
- `podman run -p 8083:8080 artifactrepo.server.ha.org.hk:55743/int-docker-dev-cms/ai-directory:latest` - Run container

### OpenShift Operations

- `oc project poc-cms-dhp-1` - Switch to project
- `oc rollout restart deployment/ai-directory` - Restart deployment

## Architecture Overview

This is a Next.js 15 application using the App Router pattern that serves as an AI directory platform. The application features three main content areas: Contexts, MCP (Model Context Protocol) servers, and Prompts.

### Key Architectural Patterns

**Hybrid Layout System**: The application uses a dual layout approach:

- Nextra theme for documentation pages (`/docs`) with automatic sidebar generation
- Custom layouts for application pages with specialized sidebars and filtering

**Co-located Components**: Components are organized alongside their respective app routes rather than in a global components directory:

- `/app/contexts/` contains context-related components
- `/app/mcp/` contains MCP-related components
- `/app/prompts/` contains prompt/rules-related components
- `/components/` contains only shared UI components and utilities

**YAML-driven Content**: Content is managed through YAML files with structured metadata:

- `contexts/` directory contains context definitions with tags.yaml for filtering
- `mcp/` directory contains MCP server configurations with tags.yaml
- `rules/` directory contains prompt templates and rules
- `content/` directory contains MDX documentation

**Dynamic Filtering System**: Each content area implements multi-select filtering:

- Context filtering by tech stacks, teams, and categories
- MCP filtering by tags with counts
- Consistent FilterGroup/Sidebar pattern across sections

### Technology Stack

- **Framework**: Next.js 15 with App Router and Turbopack
- **UI**: Radix UI primitives with custom component library
- **Styling**: Tailwind CSS v4 with custom animations
- **Content**: Nextra for docs, YAML + gray-matter for structured content
- **State**: React Server Components with client-side filtering
- **Deployment**: Container-based with OpenShift

### Data Flow Patterns

**Server-Side Content Loading**: Content is loaded server-side in layout components and passed to client components for filtering and display.

**URL-based State Management**: Filter states are managed through URL search parameters, enabling shareable filtered views.

**File-based Routing**: Follows Next.js App Router conventions with special handling for:

- `[slug]` dynamic routes for individual content items
- `[...slug]` catch-all routes for nested documentation
- Layout components that provide sidebar navigation

### Import Patterns

The codebase uses relative imports for co-located components and absolute imports (`@/`) for shared utilities:

```typescript
// Co-located components use relative imports
import { ContextCard } from "./ContextCard";

// Shared utilities use absolute imports
import { cn } from "@/lib/utils";
```

### Content Structure

Each content type follows a consistent pattern:

- Individual YAML files define content items
- tags.yaml defines available filter categories
- Layout components handle server-side data loading
- Client components handle filtering and display
- Dynamic routes render individual content pages
