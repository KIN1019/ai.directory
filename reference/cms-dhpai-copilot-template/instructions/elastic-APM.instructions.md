---
description: Sample configuration for elastic APM setup
applyTo: "**/*.{yml,yaml}"
---

# Implement the following two rules

1. Prioritize values.yaml above all others
2. If an apm block is present in values.yaml, disregard apm settings in any values-\*.yaml files

## APM Agent Environment Variables Configuration

- **Helm Values File(s):** `values-DEV.yaml`  
  **Target APM Console:** APM Console (DEV)  
  **Environment Variables (env section):**

  ```yaml
  env:
    - name: ENABLE_APM_AGENT
      value: "true"
    - name: APM_URL
      value: "https://eapm-gateway.aiops-corp-eapm-dev.svc. cluster.local:8400"
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

- **Helm Values File(s):** `values-SIT-C1.yaml`, `values-SIT-C2.yaml`, `values-LPT-C2.yaml`, `values-AAT-C1.yaml`, `values-AAT-C2.yaml`  
  **Target APM Console:** APM Console (SIT)  
  **Environment Variables (env section):**

  ```yaml
  env:
    - name: ENABLE_APM_AGENT
      value: "true"
    - name: APM_URL
      value: "https://eapm-gateway.aiops-corp-eapm-sit.svc. cluster.local:8400"
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

- **Helm Values File(s):** `values-PRD-C1.yaml`, `values-PRD-C2.yaml`  
  **Target APM Console:** APM Console (PRD)  
  **Environment Variables (env section):**

  ```yaml
  env:
    - name: ENABLE_APM_AGENT
      value: "true"
    - name: APM_URL
      value: "https://eapm-gateway.aiops-corp-eapm-prd.svc. cluster.local:8400"
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
