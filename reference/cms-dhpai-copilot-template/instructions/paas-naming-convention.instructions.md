---
description: paas naming convention
applyTo: "**/*"
---

# Naming Convention & Legend

### Convention Rules

- `[item]` → **optional** (item in square brackets)
- `<item>` → **mandatory** (item in angle brackets)
- **Name** format (unless otherwise specified):  
  `[a-z][0-9a-z]*`  
  → Only lowercase letters and numbers  
  → First character must be a letter  
  → Hyphen `-` is reserved as separator (cannot be used inside a name segment due to OpenShift/Kubernetes restrictions)

### Common Legend

| Placeholder | Description                          | Allowed Format   |
| ----------- | ------------------------------------ | ---------------- |
| `product`   | Product code from Product Profile    | `[a-z][0-9a-z]*` |
| `module`    | Module code from Product Profile     | `[a-z][0-9a-z]*` |
| `submodule` | Sub-module code from Product Profile | `[a-z][0-9a-z]*` |
| `function`  | Function code from Product Profile   | `[a-z][0-9a-z]*` |
| `usage`     | Short descriptive text               | `[a-z][0-9a-z]*` |

# PaaS Object Labeling Standard

For each PaaS object, you may add custom labels for your own use (e.g., grouping objects for an application).

## Official Kubernetes Labeling Convention (Reference)

- Format: `<prefix>/<attribute>`
- Examples:
  - `app.kubernetes.io/name: mysql`
  - `app.kubernetes.io/instance: mysql-prod`
- OpenShift variant: `<prefix>/<object>.<attribute>`
  - Example: `openshift.io/deployment.name: test-app`

**Key Rule**  
Labels **with** a prefix (ending with `/`) are considered official/standard.  
Labels **without** any prefix are treated as **user-private** and safe from name collisions.

**Recommendation**  
Define your own custom labels **without** a prefix.

## Reserved Label (Mandatory for Alerting)

| Label                | Purpose                                                                           | Example Value              |
| -------------------- | --------------------------------------------------------------------------------- | -------------------------- |
| `alert.project-code` | Used by Operations team to route alerts (email/pager) to the correct support team | `alert.project-code: ABCD` |

**Value must be the official Call Centre project code** of your application.

### Project Code Requirements (BPPM & Call Centre)

- Maximum 15 characters
- No spaces or special characters
- Must already exist in **Call Centre** before creating in BPPM
- Must be identical in both systems
- Use group email/distribution list (not individual emails) as alert recipient

### Links

| Purpose                           | URL                                                                            |
| --------------------------------- | ------------------------------------------------------------------------------ |
| BPPM Project Profile Enquiry      | http://bppm-web-prod.server.ha.org.hk/TS_patrol/ProjectProfile.aspx            |
| Call Centre Support Lookup        | http://cc.home/v2/secure/Support-Lookup.aspx                                   |
| Submit TSR for Alert Notification | https://tsr-itsupport-tsr-prd.prdcld1.ha.org.hk/#/alert_email_notification/new |

**Reminder**: Always verify the project code exists and matches in both Call Centre and BPPM before using it in the `alert.project-code` label.

# PaaS Object Naming Standards

## 1. Namespace

Namespace name **must be unique**.

### New Convention (Recommended)

| Purpose   | Format                                                                                                     | Notes                 |
| --------- | ---------------------------------------------------------------------------------------------------------- | --------------------- |
| POC       | `poc-<product portfolio\|product line\|product>[-usage][-dmz][-seq]`                                       | Must delete after POC |
| DEV – PRD | `<product portfolio\|product line\|product>[-module\|submodule\|function\|usage\|ocpis][-dmz]-<env>[-seq]` |                       |

### Obsoleted Convention (Do NOT use for new namespaces)

- DEV: `<product>[-<corp\|cluster\|hosp\|dh\|ext>][-usage]-<env>[-<seq>]`
- SIT – PRD: `<product>[-<corp\|cluster\|hosp\|dh\|ext>][-<module\|submodule\|function\|ocpis>]-<env>[-<seq>]`

### Environment Codes (`<env>`)

| Code  | Meaning                          | Remarks           |
| ----- | -------------------------------- | ----------------- |
| dev   | Development                      |                   |
| st    | System Test                      | CIMS2 alignment   |
| pot   | Product Owner Test               | PLTE mini only    |
| uat   | User Acceptance Test (dev side)  |                   |
| sit   | System Integration Test          | PLTE mini allowed |
| lpt   | Load & Performance Test          |                   |
| devqa | Developer QA before Production   | CMS request       |
| ppm   | Pre-Promotion                    |                   |
| aat   | Application Acceptance Test      | PLTE mini allowed |
| pps   | Pre-Production Site (ex-FPS/PPT) |                   |
| prd   | Production                       |                   |

### Other Tokens

| Token   | Meaning                                         |
| ------- | ----------------------------------------------- |
| seq     | 1–9 (for splitting when resource limit reached) |
| dmz     | Required for DMZ namespaces                     |
| ocpis   | Reserved for ImageStream-only namespaces        |
| corp    | Corporate (HA)                                  |
| dh      | Department of Health                            |
| ext     | External parties                                |
| cluster | hke / hkw / kec / kwc / kcc / nte / ntw         |
| hosp    | HA hospital code                                |

### Examples

**POC**  
`poc-abc-robot-1` `poc-xyz-star-dmz`

**DEV–PRD**  
`abc-prd-1` `xyz-auth-dev` `xyz-auth-dmz-dev`

## 2. Deployment (Application Name / `<app_label>`)

Must be unique within namespace.

**Format**:  
`[product-][module-][submodule-]<usage>-<type>[-version]`

- Omit `[product-]` if same as namespace product code.
- `<type>`: `svc` (service), `app` (frontend), `cjob` (CronJob), etc.
- `[-version]`: Only when parallel versions run → `A-B-C[-D[-E]]` (numeric only)

**Version Label** (separate label): `A.B.C[.D[.E]]`

### Examples

- `cms-common-session-metric-svc-1-0-1`
- `epr-auth-svc-1-0-1`
- `frontend-app`

## 3. Service Name

**Format**: `<app_label>[-usage]`

### Examples

- `poc-svc`
- `poc-svc-adminport`

## 4. Route Name

**Format**: `<app_label>[-usage]` (same as Service)

### Examples

- `poc-svc`
- `poc-svc-adminport`

## 5. GTM / Global Route DNS (External)

**OCP 4 Format**:  
`<route_name>-<namespace>.<tst|prd>cld<seq>.<ha.org.hk|hadev.org.hk>`

**Stable CNAME Options** (recommended, submit T3 request):

1. `xxxx.server.ha.org.hk` (PRD) / `xxxx.serverdev.hadev.org.hk` (non-PRD)
2. CMS only: `xxxx.cmseap.server.ha.org.hk` / `xxxx.cmseap.serverdev.hadev.org.hk`

**Short .home DNS** (optional):  
PRD: `xxxx.home` non-PRD: `xxxx-dev.home`

**Constraints**:

- Each DNS label ≤ 63 chars
- Full FQDN ≤ 253 chars
- `<route_name>-<namespace>` ≤ 63 chars

### Examples

- `cms-epr-auth-svc-1-0-1-cms-prd-1.prdcld1.ha.org.hk`
- `epr-auth-svc-cms-sit-1.tstcld1.ha.org.hk`

## 6. Local / Datacenter-Specific Route DNS

**Format**:  
`<route_name>-<namespace>.<tst|prd>cld<dc><seq>.<server.ha.org.hk|serverdev.hadev.org.hk>`

- `<dc>`: 6 (DC6) / 7 (DC7)

### Examples

- `cms-epr-auth-svc-1-0-1-cms-prd-1.prdcld71.server.ha.org.hk`
- `epr-auth-svc-cms-sit-1.tstcld61.serverdev.hadev.org.hk`

## 7. ConfigMap

**Formats**:

1. `<app_label>[-usage]-configmap`
2. `<function>-configmap` (shared across apps)

### Examples

- `cms-epr-auth-svc-1-0-1-configmap`
- `cmsipdb-configmap`

## 8. Secret

**Formats**:

1. `<app_label>[-usage]-secret`
2. `<usage>-secret` (shared)

### Examples

- `cms-epr-auth-svc-jdbc-secret`
- `cmsipdb-secret`

## 9. Persistent Volume Claim (PVC)

**Non-hostpath**:

1. `<app_label>[-usage]-pvc`
2. `<usage>-pvc` (shared)

**Hostpath (CLAP only)**:

- `hostpathcldlog-<namespace_no_hyphen>-pvc`
- `hostpathcldclap-<namespace_no_hyphen>-pvc`

### Examples

- `cms-epr-auth-svc-jdbc-pvc`
- `alsshared-pvc`
- `hostpathcldlog-cimsdmzdev-pvc`

## 10. Persistent Volume (PV)

**Non-hostpath** (auto-generated):  
`<namespace>-<pvc_name>-<random>`

**Hostpath (CLAP only)**:

- `hostpathcldlog-<namespace_no_hyphen>-pv`
- `hostpathcldclap-<namespace_no_hyphen>-pv`

## 11. Cloud / Cluster Name

**Format**: `[cld<hosp>]<prd|tst>[<cld|aic|dmz>][dc]<seq>`

### Examples

- `cldkwhtst1`
- `prddmz1`
- `tstcld61`
