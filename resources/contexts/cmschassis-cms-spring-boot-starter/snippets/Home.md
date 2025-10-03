# Welcome to the HA Spring Boot Starter wiki!

The HA Spring Boot Starter is a collection of helper libraries designed to handle common tasks, including logging, exception handling, encryption, authentication, authorization and database schema migration.

A [Quick Start](Quick-Start) guide is provided to offer a simple kickstart on how to create a new project and utilize these libraries.

If you are upgrading from a project that using [cms-spring-boot-starter](https://hagithub.ha.org.hk/CMSCHASSIS/cms-spring-boot-starter/wiki), please refer to the [Upgrade to Spring Boot 3](Upgrade-to-Spring-Boot-3) guide.

## Modules

Depends on the usage, developers are freely to include any one of the following modules:

- [ha-spring-boot-starter-core](Module-Core) - Exception handling, logging and encryption.

- [ha-spring-boot-starter-migrate](Module-Migrate) - Database schema initialization and migration.

- [ha-spring-boot-starter-security](Module-Security) - Authentication and authorization.

## Dependency Management

Please include the Dependency Management section to ensure that the required libraries and dependencies are automatically resolved and included in the build process.

```xml
<project>
    <properties>
        <ha-spring-boot-starter.version>3.1.1</ha-spring-boot-starter.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>hk.org.ha</groupId>
                <artifactId>ha-spring-boot-starter</artifactId>
                <version>${ha-spring-boot-starter.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

> Please refer to [this page](https://hagithub.home/CDRA/workflow-template/blob/main/doc/artifactory-setup.md#access-chassis-dependencies-and-libraries) to request CDC3 to setup `chassis` linkage to your repo.

### Compatible Version for Dependence

If you require an older version of the HA Spring Boot Starter, please use the appropriate dependency version.

| Released Date | ha-spring-boot-starter | spring-boot-starter-parent | spring-cloud-dependencies | JDK |
| ------------: | :--------------------: | :------------------------: | :-----------------------: | :-: |
|   11 Apr 2025 |        `3.1.1`         |           3.3.10           |         2023.0.5          | 17+ |
|    6 Mar 2025 |        `3.1.0`         |           3.3.9            |         2023.0.5          | 17+ |
|   15 Nov 2024 |        `3.0.0`         |           3.2.8            |         2023.0.3          | 17+ |

## Change Logs

### Release v3.1.1

- feat: add legacy support for locationcode and device-id in request logging
- feat: only enable warning log if deviceid is not given

### Release v3.1.0

- feat: update console-log-pattern and add span id in response body
- feat: add device id support
- feat: enable spring only auth by config
- feat: add renamed als4 fields for backward compatibility
- chore: trim cms local user to user code only

### Release v3.0.0

- Initial Release
