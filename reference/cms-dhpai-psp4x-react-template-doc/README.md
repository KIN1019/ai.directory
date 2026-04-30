# PSP List Migration Template

An AI-primary template for migrating ExtJS PSP patient lists to React. This repo provides a **reference implementation** and **AI skills** so that Cursor agents can systematically convert legacy `pspList.js` files into modern React components.

## How It Works

1. Place your legacy `pspList.js` file in the repo root
2. Ask the Copilot agent to migrate it using the `migrate-psp-list` skill
3. The agent follows a structured multi-phase workflow (analysis → types → API → columns → toolbar → filters → main component)
4. The result is a customized React module under `src/modules/psp-list/`

> The migration skill is located at `.github/skills/migrate-psp-list/SKILL.md` and is automatically picked up by the Cursor agent.

## Reference Implementation

The `src/modules/psp-list/` directory contains a working reference implementation with:

- **`DataGridSplit`** — Split-panel grid component with synchronized scrolling
- **`Dropdown`** / **`DatePicker`** / **`StatBox`** — Reusable toolbar components
- **Hooks** — Filter logic, sort model, keyboard navigation, row selection, and more
- **Types** — TypeScript interfaces for patient data and grid configuration
- **Dummy data** — Mock data for UI development without backend dependency

## Prerequisites

### Quick Start with Hub App Simulator

```sh
# Install dependencies and build
npm ci
# Run with local server
npm run start`
```

Once the app is started successfully, access `http://localhost:3010/` to see the result.

## Project Structure

```
src/modules/psp-list/
  PspList.tsx                  # Main component (customize this)
  components/
    data-grid-split/           # Split-panel grid (DO NOT recreate)
    Dropdown.tsx               # Dropdown control
    DatePicker.tsx             # Date picker control
    StatBox.tsx                # Stat counter
  data/
    dummy.ts                   # Mock patient data
  hooks/                       # Filter, sort, scroll, selection hooks
  services/
    patientApi.ts              # API service (dummy data by default)
  types/
    patient.ts                 # Patient data interfaces
    grid.ts                    # Grid configuration types
  theme/
    pspTheme.ts                # MUI theme overrides
```

## AI Skills

Skills in `.github/skills/` provide structured guidance to Cursor agents:

| Skill                            | Purpose                                              |
| -------------------------------- | ---------------------------------------------------- |
| **`migrate-psp-list`**           | Core migration workflow — ExtJS `pspList.js` → React |
| `setup-npmrc`                    | Configure NPMRC for internal registry                |
| `systematic-debugging`           | Root cause analysis and defense-in-depth debugging   |
| `executing-plans`                | Follow multi-step plans systematically               |
| `writing-plans`                  | Create structured implementation plans               |
| `verification-before-completion` | Verify work before marking complete                  |
| `writing-skills`                 | Author new skills                                    |

## Key Migration Concepts

| ExtJS Pattern                   | React Equivalent                                         |
| ------------------------------- | -------------------------------------------------------- |
| `Ext.grid.GridPanel`            | `DataGridSplit` component                                |
| `Cui.ComboBox`                  | `Dropdown` component                                     |
| `Ext.form.DateField`            | `DatePicker` component                                   |
| `Ext.data.Store` + `filterBy()` | React state + `useMemo` filters                          |
| `setVisible(false)`             | Conditional rendering `{show && <Component />}`          |
| Sort dropdown in toolbar        | Column header click sorting (built into `DataGridSplit`) |

For the full mapping, see `.github/skills/migrate-psp-list/resources/extjs-to-react-mapping.md`.

## Deployment

- Other configurations
  - [Port](https://hagithub.ha.org.hk/CMSCHASSIS/cms-plugin-app-template/#port)

  - [HTTPS](https://hagithub.ha.org.hk/CMSCHASSIS/cms-plugin-app-template/#https)

### 3.1 Configure your Plugin

#### 3.1.1 Assign a CMS Plugin ID

You need a unique id for this plugin and modify it at [`pluginId.ts`](/src/cms-plugin/pluginId.ts). This pluginId should generally be as broad as the product line/ module and may include a sub-module under [Product Profile](http://eao.home/pp/). (e.g. SmartPanel, ResultScreening, PatientTags, OTRecords, OTRecordsOtrs)

```tsx
// A unique plugin identifier in Upper Camel case
pluginId: "SmartPanel";
```

> Important Note: this is a unique ID in the CMS platform. Please contact <cmschassissupp@ho.ha.org.hk> for the registration first.

#### 3.1.2 Set a package name for this npm project

Edit "name" in `package.json`. This should match your Git repository name normally.

For example

```
{
  "name": "cms-result-screening-app",
  ...
```

<br/>

## 4. Deploy to ECP

### 4.1 Workflow and Platform Configurations

#### 4.1.1 Repo setup

Please refer to [Required Repository Variables for Using the CDRA Reusable Workflow](https://hagithub.home/CDRA/workflow-template/blob/release/doc/variable-setup.md#required-repository-variables-for-using-the-cdra-reusable-workflow) to make sure your repo is setup correctly.

Some essential environment variables

| Name             | Value                                                                                                                                                                            |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| APP_NAME         | {Your Application Name}                                                                                                                                                          |
| NAMESPACE\_{ENV} | cms-ae-{env}/ cms-fn-{env}/ cms-oz-{env}<br />Check [here](http://cmscommon.home/cmspaas/Deployment%20Workflow%20%20Wiki%20Lib/CMS%20OCP%20Namespaces.aspx) for more information |
| NODE_VERSION     | 20                                                                                                                                                                               |

#### 4.1.2 Github workflows

In order to facilitate faster development, this template includes the cms-development-workflow in `.github/workflows/.cms-development-workflow.yml`.

> NOTE: This will primarily work for `CMS` Github repositories, which the organization has already well pre-set most of the required variables for the workflow. However, this workflow in this template is for demonstration purposes only and may not be up-to-date.
>
> Always refer to the [CMS Workflow Template Wiki](https://hagithub.home/CMS/cms-workflow-template/wiki/CMS-GitHub-Actions-ECP-Starter-Guide-for-DEV-Team) for latest information.

For other GitHub repository, workflow and settings, please refer to the following: [CMS Workflow Template Wiki](https://hagithub.home/CMS/cms-workflow-template/wiki/CMS-GitHub-Actions-ECP-Starter-Guide-for-DEV-Team).

#### 4.1.3 Helm

We have provided a basic helm chart located at`deployment-package/DP_110_ecp_deployApp/values-DEV.yaml` , which you MUST EDIT as required.

You can search for `<change-it>` to find places that requires modification.

For more information, please refer to: [CMS Workflow Template Wiki - Helm Deployment Guide](https://hagithub.home/CMS/cms-workflow-template/wiki/CMS-GitHub-Actions-ECP-Starter-Guide-for-DEV-Team#helm-deployment-guideline).

#### 4.1.4 Docker build

Please note that the Dockerfile includes Node.js to build the source, as required to support multiple runners. The current version is set to Node 20 at time of this writing.

> The Dockerfile primarily sets up the Nginx configuration and builds a `remoteEntry.js` JavaScript bundle for the CMS Hub App to integrate. It also adds a `/healthcheck` endpoint for ECP monitoring.

<br/>

## 5. Advance Configurations for local development

### 5.1 Port

This plugin need to run at specific port, it is `3010` by default.

```
PORT=3010
```

### 5.2 HTTPS

It is best to enable `HTTPS` on local dev to avoid unnecessary issues. To do this, please follow [this guide on how to create the necessary certs](https://github.com/FiloSottile/mkcert). Place the generated certs inside the root directory of this repo (Note: you may need to rename the files or change the names in the `.env.local` to match).

```dotenv
### DEV - support HTTPS ###
### Add cert generated with https://github.com/FiloSottile/mkcert ###
HTTPS=true
SSL_CRT_FILE=./localhost.pem
SSL_KEY_FILE=./localhost-key.pem
```

## 6. Additional Resources

You can learn more about the CMS MX Plugin development at

For backend development (API, Database, Security, etc.), you can get started with the following template

- [cms-svc-template](https://hagithub.home/CMSCHASSIS/cms-svc-template)
