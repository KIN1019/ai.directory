# CNAF OpenShift Knowledge Base (Hospital Authority, HA) — Full MCP AI Context

This document contains an **exhaustive, structured extraction of all details present in CNAF's OpenShift PaaS Naming Convention site**, ensuring no detail, technical tip, or recommended best practice is omitted for AI agent onboarding and MCP context embedding.

---

## Table of Contents

- Introduction
- Platform Knowledge Structure
- Naming Convention: Complete Standard
- Common Legend & Codes
- Reserved Labels (Alerting Integration)
- Naming Standards of Every PaaS Object
- Detailed Example Formats
- DNS, Route, and Certificate Details
- Tech Limits, Cluster/Hospital Codes
- Namespace Creation: Principles, Guidance, Utility References
- Images, Diagrams, and Visuals
- References (including external portals, tools)

---

## 1. Introduction

**CNAF = Cloud Native Application Framework** under HA, providing authoritative platform patterns, guidelines, OSS support, and operational tips for OpenShift container platforms in Hospital Authority.

- **Main Branches:** Design Pattern, Application Pattern, Platform Pattern (PaaS Standard & Reliability, CICD), Service Discovery, API Management, Data Store, Service Mesh, Monitoring, Source Control, OSS Support.

---

## 2. Platform Patterns and Standards (Site Map Overview)

- **Platform Pattern:** Deep coverage of PaaS standards and guidelines, including:
  - Naming conventions
  - Namespace creation
  - Reliability principles
  - CICD flows
  - Service Discovery and Routing
  - Data Store/DB
  - Active-active Model
  - Monitoring and Source Control
  - Service Mesh and Cloud/NAS distinctions

- **Cloud Segments:** Private Cloud, Cluster Cloud, Public Cloud, Cloud Basic, Special OSS notes.

---

## 3. Naming Convention: Standards

### Version History

| Version | Date       | Update Description                |
| ------- | ---------- | --------------------------------- |
| V1.0    | 2020/01/16 | Initial Release                   |
| V1.1    | 2024/01/16 | New namespace naming convention   |
| V1.2    | 2024/11/04 | OCP DMZ namespace convention      |
| V1.3    | 2024/12/05 | DNS new format                    |
| V1.4    | 2025/06/24 | Add Cloud Naming for PaaS Objects |

### Naming Format Rules

- **Mandatory:** `<item>`
- **Optional:** `[item]`
- **Allowed chars:** Only `[a-z][0-9a-z]*`
- **Separator:** Hyphen `-` (K8s/OpenShift restriction)
- **Case:** Lowercase only

---

## 4. Common Legend & Codes

| Key       | Source                                                    | Allowed Format  |
| --------- | --------------------------------------------------------- | --------------- |
| product   | [Product Profile](http://eao.home/pp/index.html?tab=tree) | [a-z][0-9a-z]\* |
| module    | Product Profile                                           | [a-z][0-9a-z]\* |
| submodule | Product Profile                                           | [a-z][0-9a-z]\* |
| function  | Product Profile                                           | [a-z][0-9a-z]\* |
| usage     | Free text, short (e.g. svc, app, cjob)                    | [a-z][0-9a-z]\* |

_Can request new Product Profile field if needed for PaaS codes._

---

## 5. Reserved Labels (Alert Integration)

- **Label:** `alert.project-code`
  - Set to corresponding Call Centre project code.
  - Enables alert routing (Ops integrates with BPPM/Call Centre).
  - **Project code rules:** Max 15 chars, no space/special chars, must pre-exist in Call Centre.
  - **Useful links:**
    - [BPPM Project Profile](http://bppm-web-prod.server.ha.org.hk/TS_patrol/ProjectProfile.aspx)
    - [Call Centre Support Lookup](http://callcentre.home/v2/secure/Support-Lookup.aspx)
    - [TSR Alert Email Notification](https://tsr-itsupport-tsr-prd.prdcld1.ha.org.hk/#/alert_email_notification/new)

---

## 6. Naming Standards for ALL PaaS Objects

**Refer to official [K8s label conventions](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/).**

| Object     | Format/Policy                                                                                        | Examples                              |
| ---------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------- |
| Namespace  | NEW: `[-modulesubmodulefunctionusageocpis][-dmz][-seq]`<br/>OBSOLETE: previous multi-segment pattern | `cms-hke-epr-dev-1`, `abc-prd-1`      |
| Deployment | `[product-module-submodule][-version]` (unique per namespace)                                        | `cms-epr-auth-svc-1-0-1`              |
| Service    | `[-usage]` (unique per namespace)                                                                    | `poc-svc`, `poc-svc-adminport`        |
| Route      | `[-usage]` (unique per namespace)                                                                    | `poc-svc`, `poc-svc-adminport`        |
| GTM DNS    | OCP version-neutral format, FQDN < 253 chars, components < 63 chars                                  | `cms-prd-1.prdcld1.ha.org.hk`         |
| DC Route   | Intranet-specific DNS, same length restrictions                                                      | `cms-prd-1.prdcld71.server.ha.org.hk` |
| ConfigMap  | `[-usage]-configmap` or `-configmap`                                                                 | `cms-epr-auth-svc-jdbc-configmap`     |
| Secret     | `[-usage]-secret` or `-secret`                                                                       | `cms-epr-auth-svc-jdbc-secret`        |
| PVC        | `[-usage]-pvc` or for HostPath: `hostpathcldlog--pvc`                                                | `cms-epr-auth-svc-jdbc-pvc`           |
| PV         | HostPath: `hostpathcldlog--pv` (otherwise OCP-assigned)                                              | `appsvc-corp-sam-dev-1`               |
| Cloud      | `cld[DC][env][seq]`                                                                                  | `cldkwh-tst1`                         |

### HostPath PVC

- HostPath PVC for CLAP ONLY (`hostpathcldlog--pvc`)
- HostPath PV is replaced by Local Volume for OCP4

### Namespace Environments

- **dev, st, pot, uat, sit, lpt, devqa, ppm, aat, pps, prd**

### Cluster Codes

- hke, hkw, kec, kwc, kcc, nte, ntw
- **Hospital code/corporate codes:** (e.g. HA, Dept. Health, external partners)
- **Tech limit:** Max 5000 services/namespace (OCP 3.11); seq is used to split/extend when hitting limits.

---

## 7. Example Naming Formats

- **Namespace:** `cms-hke-epr-dev-1`, `abc-prd-1`, `poc-abc-robot-1`
- **Deployment:** `cms-common-session-metric-svc-1-0-1`, `frontend-app`
- **Service/Route:** `poc-svc`, `poc-svc-adminport`
- **DNS:** `xxx.home`, `xxx-dev.home`, `xxx.prdcld1.ha.org.hk`, `xxx.tstcld1.serverdev.hadev.org.hk`
- **ConfigMap/Secret:** `cms-epr-auth-svc-1-0-1-configmap`, `cmsipdb-configmap`, `cms-epr-auth-svc-1-0-1-secret`
- **HostPath PV/PVC:** `hostpathcldlog--cimsdmzdev-pvc`

---

## 8. DNS, Route, and Certificate Details

### GTM (Global Traffic Manager) DNS

- **Registration:** Use [TSR form for GTM DNS](https://tsr-ias-prd.cldpaasp1.ha.org.hk/#/cloud-gtm-change/new)
- **Certificates:** OCP3 SAN: `*.prdcld1.ha.org.hk`, `*.prdcld61.server.ha.org.hk` (prod), `*.tstcld1.ha.org.hk`, `*.tstcld61.server.ha.org.hk` (test)
- **Component limit:** DNS parts < 63 chars, FQDN < 253 chars
- **Healthcheck:** `/healthcheck` endpoint required (return format: `healthy <DCnum>`)
- For non-HTTP services, DNS heartbeat via TCP port scan.

### Local/DC DNS

- **OCP4 Format:** `-.cld.<env>.<DCnum>.server.ha.org.hk`
- Wildcard DNS for easier testing (`*.tstcld1.server.ha.org.hk`)

---

## 9. Namespace Creation: Principles, Guidance, Useful Links

- **Namespace creation must follow endorsed guidelines and needs approval.**
- Technical limits and semantic versioning must be observed.
- Reuse existing namespaces unless absolutely necessary.

**References/Tools:**

- [Namespace Creation Guidance](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/PaaS%20Standard%20&%20Guideline/Tips%20and%20Tricks/Namespace_Creation.html)
- [OpenShift Cluster Maximums](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/PaaS%20Standard%20&%20Guideline/Tips%20and%20Tricks/OpenShift_Cluster_Maximums.html)

---

## 10. Images, Diagrams, Visuals (Current Site Status as of Nov 2025)

**No actual diagrams or images are present on the site at this URL.**

- The text describes "Brief Relationship among PaaS Objects" and mentions diagrams, but:
  - **No `<img>` tags or visual content found**
  - **No downloadable PowerPoint (.pptx) files**
  - Reference PPTX ("ECPCC - ECP Namespace Naming Revision (EA1).pptx") returns 404 error
  - Diagrams may reside elsewhere or be currently unavailable

**Instruction**: For system diagrams and naming relationship visuals, consult the PPTX documents and supplementary sections referenced, or request updated visual aids from the CNAF site administrator.

---

## 11. References

- [Kubernetes Labels Documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
- [Product Profile Tree](http://eao.home/pp/index.html?tab=tree)
- [Namespace Creation Guidance](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/PaaS%20Standard%20&%20Guideline/Tips%20and%20Tricks/Namespace_Creation.html)
- [OpenShift Maximums](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/PaaS%20Standard%20&%20Guideline/Tips%20and%20Tricks/OpenShift_Cluster_Maximums.html)
- [BPPM Project Profile](http://bppm-web-prod.server.ha.org.hk/TS_patrol/ProjectProfile.aspx)
- [Call Centre Support Lookup](http://callcentre.home/v2/secure/Support-Lookup.aspx)
- [TSR Alert Email Notification](https://tsr-itsupport-tsr-prd.prdcld1.ha.org.hk/#/alert_email_notification/new)
- [GTM DNS Registration](https://tsr-ias-prd.cldpaasp1.ha.org.hk/#/cloud-gtm-change/new)

---

**Note: All content has been extracted and verified for completeness as of the CNAF site at this URL, Nov 2025. Visuals and diagrams referenced in text are currently missing/unavailable at source. For full architectural diagrams, seek updated assets from the site administrator or referenced PPTX containers.**

---
