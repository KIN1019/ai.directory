# Change Log

All notable changes to the "awesome-copilot-ghe" extension will be documented in this file.

## [1.1.0] - Chatmodes to Agents Migration

### Changed

- **Complete Chatmodes to Agents Migration**: All chatmodes have been migrated to the agents format
  - Migrated `cms-dhpai-copilot-booster-doc.chatmode.md` → `cms-dhpai-copilot-booster.agent.md`
  - Migrated `cms-dhpai-sp-evaluation-doc.chatmode.md` → `cms-dhpai-sp-evaluation.agent.md`
  - Migrated `CRA-PullRequest.chatmode.md` → `code-review-agent.agent.md`
- Updated extension logic to use agents instead of chatmodes
- Updated all documentation to reflect the new agents-only structure

### Removed

- **Chatmodes category deprecated**: The chatmodes resource type has been removed
- Removed `chatmodes/` directory and all chatmode files
- Removed chatmodes handling from installer, pickers, search tool, and install tool

### Technical Changes

- Updated `IndexData` interface to remove chatmodes property
- Updated `generate-index.cjs` to generate agents instead of chatmodes
- Updated `generate-docs.js` to process agents directory only
- Updated category arrays throughout the extension codebase
- Updated instruction files `applyTo` fields to reference agents instead of chatmodes

### Migration Notes

- Agents use XML tag structure (`<persona>`, `<task>`, `<instructions>`) for better structured prompts
- Existing chatmode content has been preserved in the new agent format
- All agent files now use the `.agent.md` extension

## [1.0.0] - Initial Release

### Added

- **Multiple Authentication Methods**:
  - OAuth (web-based browser login) - Best UX
  - Basic Auth (username/password) - Easiest, no setup
  - Personal Access Token (PAT) - Traditional method
- Interactive authentication method picker
- Browse and explore instructions, prompts, agents, and collections
- Install items globally or to workspace
- Collection support with bulk installation
- Smart picker memory (remembers last selections)
- Support for `.github/copilot-instructions.md`
- Secure token storage using VS Code Secret Storage API
- Progress notifications for long-running operations
- Logout command to clear credentials

### Features

- **Categories**:
  - Instructions: Coding styles and best practices
  - Prompts: Task-specific templates
  - Agents: AI assistant behavior profiles
  - Collections: Curated bundles

- **Installation Options**:
  - View content in untitled editor
  - Install globally (User directory)
  - Install to workspace (.github folders)
  - Install to copilot-instructions.md (with append/replace)

### Configuration

- Configurable GitHub Enterprise base URL
- Configurable repository and branch
- Default values for hagithub.home/CMS/cms-dhpai-copilot-template
