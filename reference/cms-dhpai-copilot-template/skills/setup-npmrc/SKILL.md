---
name: setup-npmrc
description: "Guidance for Setting up .npmrc for internal registry"
---

You should check if the `.npmrc` with correct setting exist in the repo. If no, you should help the user to write the `.npmrc` with the correct configuration and run login command.

1. Ask which registry the user wants to use.
   - `https://artifactrepo.server.ha.org.hk:55743/artifactory/api/npm/npm-dev-cmschassis/`
   - `https://artifactrepo.server.ha.org.hk:55743/artifactory/api/npm/npm-rel-cms/`
2. Create `.npmrc` in project root (required for internal registry):
   ```
   registry = https://artifactrepo.server.ha.org.hk:55743/artifactory/api/npm/npm-dev-cmschassis/
   ```
3. Run `npm login`.
