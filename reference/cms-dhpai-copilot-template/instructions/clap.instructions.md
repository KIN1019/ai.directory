---
description: Sample configuration for clap setup
applyTo: "**/*.{yml,yaml}"
---

# Implement the following two rules

1. Prioritize values.yaml above all others
2. If an apm block is present in values.yaml, disregard apm settings in any values-\*.yaml files

## Deployment YAML – Required Label Example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  generation: 2
  labels:
    app: eap-samplewar-app
    alert.project-code: EAP # ← Required reserved label
  name: eap-samplewar-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: eap-samplewar-app
      deployment: eap-samplewar-app
  template:
    metadata:
      labels:
        app: eap-samplewar-app
        deployment: eap-samplewar-app
        alert.project-code: EAP
```
