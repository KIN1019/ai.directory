---
description: openjdk version
applyTo: "**/*.Dockerfile, **/Dockerfile"
---

# ECP Image for Spring Boot (OpenJDK 21)

| Item                               | Details                                            |
| ---------------------------------- | -------------------------------------------------- |
| **Base Image**                     | `registry.access.redhat.com/ubi8/openjdk-21`       |
| **Latest Image Tag**               | `openjdk21ecp-v25.11-openjdk21-21.0.9-conjur-13.0` |
| **APM**                            | eAPM (Elastics APM agent)                          |
| **Sample Project (GitHub Action)** | `openjdk21-eapm-eap-samplejar-githubaction-app`    |

### Image Release History

| Image Tag      | Health Index                | Release Date | Changes                                                                                                  |
| -------------- | --------------------------- | ------------ | -------------------------------------------------------------------------------------------------------- |
| **ECP-v25.11** | Green                       | 24-Nov-2025  | • OpenJDK to v21.0.9<br>• Elastic APM v1.55.1                                                            |
| **ECP-v25.08** | Green                       | 25-Aug-2025  | • OpenJDK to v21.0.8<br>• Elastic APM v1.55.0<br>• Added java option `-Delastic.apm.cloud_provider=none` |
| **ECP-v25.05** | Yellow (Update Recommended) | 20-May-2025  | • OpenJDK to v21.0.7<br>• Elastic APM v1.53.0                                                            |

**Note**: ECP image users should schedule application update on base image (ECP-v25.05 is Yellow).
|

# ECP Image for Spring Boot (OpenJDK 17)

| Item                               | Details                                                                                                        |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Base Image**                     | `registry.access.redhat.com/ubi8/openjdk-17`                                                                   |
| **Latest Image Tag**               | `openjdk17ecp-v25.11-openjdk17-17.0.17-conjur-13.0`                                                            |
| **APM**                            | eAPM (Elastics APM agent) <br>iAPM (AppDynamic APM agent)                                                      |
| **Sample Project (GitHub Action)** | eAPM: `openjdk17-eapm-eap-samplejar-githubaction-app`<br>iAPM: `openjdk17-iapm-eap-samplejar-githubaction-app` |
| **Sample Project (Jenkins)**       | eAPM: `openjdk17-eapm-eap-samplejar-app`<br>iAPM: `openjdk17-iapm-eap-samplejar-app`                           |

            |

### Both Release History

| Image Tag      | Health Index                | Release Date | Changes                                                                                                   |
| -------------- | --------------------------- | ------------ | --------------------------------------------------------------------------------------------------------- |
| **ECP-v25.11** | Green                       | 24-Nov-2025  | • OpenJDK to v17.0.17<br>• Elastic APM v1.55.1                                                            |
| **ECP-v25.08** | Green                       | 25-Aug-2025  | • OpenJDK to v17.0.16<br>• Elastic APM v1.55.0<br>• Added java option `-Delastic.apm.cloud_provider=none` |
| **ECP-v25.05** | Yellow (Update Recommended) | 20-May-2025  | • OpenJDK to v17.0.15<br>• Elastic APM v1.53.0                                                            |

**Note**: ECP image users should schedule application update on base image (ECP-v25.05 is Yellow).

### eAPM Release History

| Image Tag      | Health Index                | Release Date | Changes                                                                                                                        |
| -------------- | --------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| **ECP-v25.02** | Yellow (Update Recommended) | 24-Feb-2025  | • OpenJDK to v17.0.14<br>• Elastic APM v1.52.1<br>• Support "CUSTOM_LABEL" environment variable for customized display on eAPM |
| **ECP-v24.11** | Red                         | 15-Nov-2024  | • OpenJDK to v17.0.13<br>• Elastic APM v1.52.0<br>• Added java options "-Djava.net.preferIPv4Stack=true"                       |
| **ECP-v24.08** | Red                         | 15-Aug-2024  | • OpenJDK to v17.0.12<br>• Elastic APM v1.50.0                                                                                 |
| **ECP-v24.05** | Red                         | 15-May-2024  | • OpenJDK to v17.0.11<br>• Elastic APM v1.49.0                                                                                 |
| **ECP-v24.02** | Red                         | 15-Feb-2024  | • OpenJDK to v17.0.10<br>• Elastic APM v1.45.0                                                                                 |
| **ECP-v23.11** | Red                         | 15-Nov-2023  | • OpenJDK to v17.0.9<br>• Elastic APM v1.43.0<br>• Support BPPM integration<br>• Conjur package v13.0                          |

**Note**: ECP image users must update base image immediately.

### iAPM Release History

| Image Tag      | Health Index                | Release Date | Changes                                                                                                       |
| -------------- | --------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------- |
| **ECP-v25.02** | Yellow (Update Recommended) | 24-Feb-2025  | • OpenJDK to v17.0.14                                                                                         |
| **ECP-v24.11** | Red                         | 15-Nov-2024  | • OpenJDK to v17.0.13<br>• iAPM agent v24.8.1.36301<br>• Added java options "-Djava.net.preferIPv4Stack=true" |
| **ECP-v24.08** | Red                         | 15-Aug-2024  | • OpenJDK to v17.0.12                                                                                         |
| **ECP-v24.05** | Red                         | 15-May-2024  | • OpenJDK to v17.0.11<br>• iAPM agent v24.2.0.35552                                                           |
| **ECP-v24.02** | Red                         | 15-Feb-2024  | • OpenJDK to v17.0.10<br>• iAPM agent v23.9.0.3511<br>• Support BPPM integration<br>• Conjur package v13.0    |

**Note**: ECP image users must update base image immediately.

# ECP Image for Spring Boot (OpenJDK 8)

| Item                               | Details                                                                                                      |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Base Image**                     | `registry.access.redhat.com/ubi8/openjdk-8`                                                                  |
| **Latest Image Tag**               | `openjdk18:ecp-v25.11-openjdk8-1.8.0.472`                                                                    |
| **APM**                            | eAPM (Elastics APM agent)<br>iAPM (AppDynamic APM agent)                                                     |
| **Sample Project (GitHub Action)** | eAPM: `openjdk8-eapm-eap-samplejar-githubaction-app`<br>iAPM: `openjdk8-iapm-eap-samplejar-githubaction-app` |
| **Sample Project (Jenkins)**       | eAPM: `openjdk8-eapm-eap-samplejar-app`<br>iAPM: `openjdk8-iapm-eap-samplejar-app`                           |

### Both Release History

| Image Tag      | Health Index                | Release Date | Changes                                                                                                  |
| -------------- | --------------------------- | ------------ | -------------------------------------------------------------------------------------------------------- |
| **ECP-v25.11** | Green                       | 24-Nov-2025  | • OpenJDK v1.8.0.472<br>• Elastic APM v1.55.1                                                            |
| **ECP-v25.08** | Green                       | 25-Aug-2025  | • OpenJDK v1.8.0.462<br>• Elastic APM v1.55.0<br>• Added java option `-Delastic.apm.cloud_provider=none` |
| **ECP-v25.05** | Yellow (Update Recommended) | 20-May-2025  | • OpenJDK v1.8.0.452<br>• Elastic APM v1.53.0                                                            |

**Note**: ECP image users should schedule application update on base image (ECP-v25.05 is Yellow).

### eAPM Release History

| Image Tag        | Health Index                | Release Date | Changes                                                                                                                                |
| ---------------- | --------------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| **ECP-v25.02**   | Yellow (Update Recommended) | 24-Feb-2025  | • OpenJDK v1.8.0.442<br>• Elastic APM v1.52.1<br>• Support "CUSTOM_LABEL" environment variable for customized display on eAPM          |
| **ECP-v24.11**   | Red                         | 15-Nov-2024  | • OpenJDK v1.8.0.432<br>• Elastic APM v1.52.0<br>• Added java options "-Djava.net.preferIPv4Stack=true"                                |
| **ECP-v24.08**   | Red                         | 15-Aug-2024  | • Update Base Image: registry.access.redhat.com/ubi8/openjdk-8<br>• OpenJDK v1.8.0.422<br>• Elastic APM v1.50.0                        |
| **ECP-v24.05**   | Red                         | 15-May-2024  | • OpenJDK v1.8.0.412<br>• Elastic APM v1.49.0                                                                                          |
| **ECP-v24.02**   | Red                         | 15-Feb-2024  | • OpenJDK v1.8.0.402<br>• Elastic APM v1.45.0                                                                                          |
| **ECP-v23.11**   | Red                         | 15-Nov-2023  | • OpenJDK v1.8.0.392<br>• Elastic APM v1.43.0                                                                                          |
| **ECP-v23.08.1** | Red                         | 15-Aug-2023  | • Elastic APM v1.42.0 (bug fix for heap usage)                                                                                         |
| **ECP-v23.08**   | Red                         | 15-Aug-2023  | • Base Image: redhat-openjdk-18/openjdk18-openshift:1.8<br>• OpenJDK v1.8.0.382<br>• Elastic APM v1.40.0<br>• Support BPPM integration |

**Note**: ECP image users must update base image immediately.

### iAPM Release History

| Image Tag      | Health Index                | Release Date | Changes                                                                                                                                         |
| -------------- | --------------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **ECP-v25.02** | Yellow (Update Recommended) | 24-Feb-2025  | • OpenJDK v1.8.0.442                                                                                                                            |
| **ECP-v24.11** | Red                         | 15-Nov-2024  | • OpenJDK v1.8.0.432<br>• iAPM agent v24.8.1.36301<br>• Added java options "-Djava.net.preferIPv4Stack=true"                                    |
| **ECP-v24.08** | Red                         | 15-Aug-2024  | • Update Base Image: registry.access.redhat.com/ubi8/openjdk-8<br>• OpenJDK v1.8.0.422                                                          |
| **ECP-v24.05** | Red                         | 15-May-2024  | • OpenJDK v1.8.0.412<br>• iAPM agent v24.2.0.35552                                                                                              |
| **ECP-v24.02** | Red                         | 15-Feb-2024  | • OpenJDK v1.8.0.402<br>• iAPM agent v23.9.0.3511                                                                                               |
| **ECP-v23.11** | Red                         | 15-Nov-2023  | • OpenJDK v1.8.0.392<br>• iAPM agent v23.9.0.35116                                                                                              |
| **ECP-v23.08** | Red                         | 15-Aug-2023  | • OpenJDK v1.8.0.382                                                                                                                            |
| **EAPc1.0.6**  | Red                         | 15-May-2023  | • OpenJDK v1.8.0.362                                                                                                                            |
| **EAPc1.0.5**  | Red                         | 15-Feb-2023  | • OpenJDK v1.8.0.352                                                                                                                            |
| **EAPc1.0.4**  | Red                         | 15-Nov-2022  | • OpenJDK v1.8.0.345                                                                                                                            |
| **EAPc1.0.3**  | Red                         | 15-Aug-2022  | • OpenJDK v1.8.0.342<br>• Update JAVA options for java.io.tmpdir to use the log path mounted by PVC, prevent tmp file consume ephemeral storage |
| **EAPc1.0.2**  | Red                         | 15-May-2022  | • OpenJDK v1.8.0.322                                                                                                                            |
| **EAPc1.0.1**  | Red                         | 15-Feb-2022  | • OpenJDK v1.8.0.312<br>• iAPM agent v21.11.4.33358                                                                                             |
| **EAPc1.0.0**  | Red                         | 15-Dec-2021  | • Base Image: redhat-openjdk-18/openjdk18-openshift:1.8<br>• OpenJDK v1.8.0.302<br>• iAPM agent v21.3.0.32281<br>• Support BPPM integration     |

**Note**: ECP image users must update base image immediately.

# ECP Image for Spring Boot (OpenJDK 11)

| Item                    | Details                                                                                |
| ----------------------- | -------------------------------------------------------------------------------------- |
| **Base Image**          | `registry.redhat.io/openjdk/openjdk-11-rhel7`                                          |
| **End-of-support Date** | 31-Oct-2024                                                                            |
| **Latest Image Tag**    | `eap-corp-eapimage-dev/openjdk11:ecp-v24.05-openjdk11-11.0.23-eapm-1.49.0-conjur-13.0` |
| **Sample Project**      | `ocp4-openjdk11-eapm-eap-samplejar-app`                                                |

### Image Release History

| Image Tag        | Health Index | Release Date | Changes                                                                 |
| ---------------- | ------------ | ------------ | ----------------------------------------------------------------------- |
| **ECP-v24.05**   | Red          | 15-May-2024  | • OpenJDK v11.0.23<br>• Elastic APM v1.49.0                             |
| **ECP-v24.02**   | Red          | 15-Feb-2024  | • OpenJDK v11.0.22<br>• Elastic APM v1.45.0                             |
| **ECP-v23.11**   | Red          | 15-Nov-2023  | • OpenJDK v11.0.21.0.9<br>• Elastic APM v1.43.0                         |
| **ECP-v23.08.1** | Red          | 15-Aug-2023  | • Elastic APM v1.42.0 (bug fix for heap usage)                          |
| **ECP-v23.08**   | Red          | 15-Aug-2023  | • OpenJDK v11.0.20.8<br>• Elastic APM v1.40.0<br>• Conjur package v13.0 |
| **EAPc1.0.6**    | Red          | 15-May-2023  | • OpenJDK v11.0.18.0.10                                                 |
| **EAPc1.0.5**    | Red          | 15-Feb-2023  | • OpenJDK v11.0.17.0.8                                                  |
| **EAPc1.0.4**    | Red          | 15-Nov-2022  | • OpenJDK v11.0.16.1.1<br>• Elastic APM v1.35.0                         |

**Note**: ECP image users must update base image immediately.
