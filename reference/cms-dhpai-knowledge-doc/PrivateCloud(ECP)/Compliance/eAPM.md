# eAPM (Elastic APM)

**All Springboot, Node.js applications deployed on ECP should have Elastic APM enabled for performance monitoring and tracing.**

This document explains how to enable Elastic APM (eAPM) for applications deployed via Helm, where to find the APM consoles per environment, and the required environment variables to enable the APM agent.

## Sub-topics

- How to enable Elastic APM? Where is the corresponding APM console?
- How to learn Elastic APM? Any workshop or online training?
- How to capture Elastic APM full page?
- How to enable Elastic APM datasource on Grafana?

---

## How to enable Elastic APM and APM console URLs

To enable eAPM, set the environment variables in the relevant Helm chart values file for the target environment. The main variables are:

- `ENABLE_APM_AGENT`: set to "true" to enable instrumentation.
- `APM_URL`: APM server URL for the environment.
- Kubernetes metadata variables (node, pod, namespace, pod UID) are commonly passed via `valueFrom`.

Below are example snippets for each environment. Place these under the `env:` section of your Helm `values-*.yaml` file for the service that needs APM.

### DEV

APM console: APM Console (DEV)

```yaml
env:
  - name: ENABLE_APM_AGENT
    value: "true"
  - name: APM_URL
    value: "https://eapm-gateway.aiops-corp-eapm-dev.svc.cluster.local:8400"
  - name: KUBERNETES_NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  - name: KUBERNETES_POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: KUBERNETES_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
  - name: KUBERNETES_POD_UID
    valueFrom:
      fieldRef:
        fieldPath: metadata.uid
```

Values file examples: `values-DEV.yaml`

### SIT

APM console: APM Console (SIT)

```yaml
env:
  - name: ENABLE_APM_AGENT
    value: "true"
  - name: APM_URL
    value: "https://eapm-gateway.aiops-corp-eapm-sit.svc.cluster.local:8400"
  - name: KUBERNETES_NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  - name: KUBERNETES_POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: KUBERNETES_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
  - name: KUBERNETES_POD_UID
    valueFrom:
      fieldRef:
        fieldPath: metadata.uid
```

Values file examples: `values-SIT-C1.yaml`, `values-SIT-C2.yaml`, `values-LPT-C2.yaml`, `values-AAT-C1.yaml`, `values-AAT-C2.yaml`

### PRD

APM console: APM Console (PRD)

```yaml
env:
  - name: ENABLE_APM_AGENT
    value: "true"
  - name: APM_URL
    value: "https://eapm-gateway.aiops-corp-eapm-prd.svc.cluster.local:8400"
  - name: KUBERNETES_NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
  - name: KUBERNETES_POD_NAME
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  - name: KUBERNETES_NAMESPACE
    valueFrom:
      fieldRef:
        fieldPath: metadata.namespace
  - name: KUBERNETES_POD_UID
    valueFrom:
      fieldRef:
        fieldPath: metadata.uid
```

Values file examples: `values-PRD-C1.yaml`, `values-PRD-C2.yaml`

---

## Notes and next steps

- If you need help adding APM agent configuration for a specific language (Java, Node.js, Python, etc.), include the application repo or the chart and I can provide the exact agent settings.
- To enable an APM datasource in Grafana, you'll typically configure a data source pointing at the APM server or use the Elasticsearch data source depending on how APM is storing traces. Provide your Grafana version and desired data source and I can add an example.
