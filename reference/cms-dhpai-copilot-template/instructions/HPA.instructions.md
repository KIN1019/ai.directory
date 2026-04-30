---
description: HPA instruction setup
applyTo: "**/*.{yml,yaml}"
---

# Enforce the two rules

# 1. values.yaml always has highest priority

# 2. If autoscaling block exists in values.yaml → skip/ignore autoscaling in any values-\*.yaml

# Namespace Environment Standard

|                                                                                                                    | Cluster Cloud<br>Non-Prod<br>HDC                              | DMZ Cloud<br>Non-Prod<br>DC6                                  | CORP Cloud Non-Prod<br>Site 1<br>HKCH | CORP Cloud Non-Prod<br>Site 2<br>DC7-PLTE | CORP Cloud Non-Prod<br>Site 3<br>NLTH                         | Cluster Cloud<br>Prod<br>HDC | DMZ Cloud<br>Prod<br>DC6/DC7 | CORP Cloud Prod<br>Site 1<br>DC6   | CORP Cloud Prod<br>Site 2<br>DC7          | CORP Cloud Prod<br>Site 3<br>NLTH | AI Cloud<br>Prod<br>DC6/NLTH |
| ------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------- | ----------------------------------------- | ------------------------------------------------------------- | ---------------------------- | ---------------------------- | ---------------------------------- | ----------------------------------------- | --------------------------------- | ---------------------------- |
| **HA Project**<br>(NS Label: `ha-app=ha`)                                                                          |                                                               | DEV<br>PPM<br>PPS<br>SIT<br>UAT<br>LPT<br>DEVQA<br>AAT<br>PPS | POC<br>SIT<br>AAT                     | SIT<br>LPT<br>AAT                         | DEV<br>UAT<br>DEVQA<br>PPM<br>PPS                             |                              | PRD                          | PRD                                | PRD                                       | PRD                               |                              |
| **AIDA project**<br>(NS Label: `ha-app=aida`)<br>\*Resilient test in AI Cloud Prod                                 |                                                               | DEV<br>PPM<br>PPS<br>SIT<br>UAT<br>LPT<br>DEVQA<br>AAT<br>PPS | AAT<br>SIT                            |                                           | DEV<br>PPM<br>PPS<br>SIT<br>UAT<br>LPT<br>DEVQA<br>AAT<br>PPS |                              | PRD                          |                                    |                                           |                                   | PRD                          |
| **Cluster project**<br>(NS Label: `ha-app=ha`)<br>*PRD resilient in CORP Cloud<br>*KWH/BTS/BBDMIS use `ha-app=bts` | DEV<br>PPM<br>PPS<br>SIT<br>UAT<br>LPT<br>DEVQA<br>AAT<br>PPS | DEV<br>PPM<br>PPS<br>SIT<br>UAT<br>LPT<br>DEVQA<br>AAT<br>PPS |                                       |                                           |                                                               | PRD                          | PRD                          | PRD<br>(TSWH<br>PMH<br>QEH<br>KWH) | PRD<br>(TKOH<br>UCH<br>OMH<br>PWH<br>PYN) |                                   |                              |

# Namespace Naming Convention & Standards

## Namespace Naming Format

For new namespace creation: Fill namespace request template → submit to ECPCC for approval.

| Type      | Format                    |
| --------- | ------------------------- | ------------ | ----------------------- | --------- | -------- | ----- | ------------------- |
| POC       | `<poc>-<product portfolio | product line | product>[-usage][-seq]` |
| DEV – PRD | `<product portfolio       | product line | product>[-module        | submodule | function | usage | ocpis]-<env>[-seq]` |

- `<>` = mandatory
- `[]` = optional
- `<env>` = dev | st | uat | sit | lpt | devqa | ppm | aat | pot | pps | prd

**Rules**

- Only lowercase letters `[a-z][0-9a-z]*`
- Hyphen `-` is reserved as separator
- Register product profile in Product Profile system before creating namespace

**Examples**

- POC: `poc-cms-robot-1`, `poc-pas-cp2-1`, `poc-lis-star`, `poc-ris-image-1`
- DEV-PRD: `cms-prd-1`, `cms-ea1-dev-1`, `cms-corp-sit-1`, `cms-corp-sit-2`, `cims-dh-prd-1`

## OpenShift v4 – AD Groups per Namespace

| Openshift Role | Description                                             |
| -------------- | ------------------------------------------------------- |
| project-admin  | Full edit rights + can manage project membership via AD |
| edit           | Can create/edit most objects, cannot manage membership  |
| view           | Read-only, cannot view secrets or membership            |

AD groups are added to namespace; membership managed by AD group admin.

## Cloud Resource Quota (per Namespace)

| Resource Type            | Default Value | Description                           |
| ------------------------ | ------------- | ------------------------------------- |
| CPU                      | 5000m         | Total CPU across all containers       |
| Memory                   | 10 GiB        | Total memory across all containers    |
| Storage                  | 10 GiB        | Total persistent disk                 |
| Ephemeral-storage        | 10 GiB        | Total ephemeral storage               |
| Persistent Volume Claims | 10            | Max number of PVCs                    |
| Pods                     | 30            | Max number of pods                    |
| Services                 | 50            | Max number of services                |
| Replication Controllers  | 50            | Max number of replication controllers |

→ Raise TSR to T6 if higher quota needed.

### Per Container Defaults (if not specified in deployment)

| Resource Type     | Default Value |
| ----------------- | ------------- |
| CPU               | 200m          |
| Memory            | 500 MiB       |
| Ephemeral-storage | 400 MiB       |

## Persistent Volume (PV) Usage

- PV only for configuration & temporary files (no replication)
- Users can expand PVC size via CLI (`spec.resources.requests.storage`)
- Max files in PV ≈ Usable PV size / 32 KB  
  Example: 1.9 GiB usable → ~62,259 files
- Housekeep unused PVCs > 14 days
- Housekeep files inside PVCs recommended

## PaaS Housekeeping Policy

### Pruning Builds

- Remove builds where BuildConfig gone or status complete/failed/error/cancelled
- Keep last 3 successful, last 1 failed/error/cancelled per BuildConfig
- Nothing younger than 4 hrs is pruned

### Pruning Deployments

- Remove zero-replica deployments where DeploymentConfig gone
- Keep last 3 zero-replica successful, last 1 failed per DeploymentConfig
- Nothing younger than 4 hrs is pruned

### Pruning Images

- Max 3 tags per ImageStream
- Never prune images < 4 hrs old or still referenced by running/pending pods, RCs, deployments, builds, etc.

### Logs Retention

- NON-PRD & PRD: 5 days

## Cluster Resource Override & HPA

### Over-commitment Ratio

| Environment         | CPU (Request : Limit) | Memory (Request : Limit) |
| ------------------- | --------------------- | ------------------------ |
| All Non-PROD & PROD | 1:10 (10%)            | 1:1.25 (80%)             |
| CIMS2 PROD          | 1:20 (20%)            | 1:1.25 (80%)             |

### Horizontal Pod Autoscaler (HPA) Example

```yaml
minReplicas: 2
maxReplicas: 10
cpuUtilization:
  averageUtilization: 700 # Scale when CPU usage > 700% of request
```
