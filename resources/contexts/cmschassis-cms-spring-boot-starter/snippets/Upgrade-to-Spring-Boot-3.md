# Upgrade to Spring Boot 3

## Review the Spring Boot 3 migration guide

Start by reviewing the official Spring Boot 3 migration guide. This document provides important information about new features, changes, and potential breaking changes introduced in Spring Boot

- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Upgrade to Spring Framework 6.x](https://github.com/spring-projects/spring-framework/wiki/Upgrading-to-Spring-Framework-6.x)

## Upgrade to JDK 17

```bat
winget uninstall EclipseAdoptium.Temurin.11.JDK
winget install EclipseAdoptium.Temurin.17.JDK
```

> For Chocolatey package manager
>
> ```bat
> choco uninstall temurin11
> choco install temurin17 -y
> ```

Setup the `JAVA_HOME` into system environment variable

```bat
rem check the java home folder
which java
> C:\Program Files\Eclipse Adoptium\jdk-17.0.8.101-hotspot\bin\java.EXE
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.0.8.101-hotspot"
```

## Update dependencies

### Update the Spring framework version

```diff
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://maven.apache.org/POM/4.0.0"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
--      <version>2.7.9</version>
++      <version>3.3.10</version>
        <relativePath /> <!-- lookup parent from repository -->
    </parent>
</project>
```

### Update Java version

Spring Boot 3 require Java 17.

```diff
<project>
    <properties>
-       <java.version>11</java.version>
+       <java.version>17</java.version>
    </properties>
</project>
```

### Update Springdoc version

https://springdoc.org/#getting-started

```diff
<project>
    <properties>
-       <springdoc.version>1.7.0</springdoc.version>
+       <springdoc.version>2.6.0</springdoc.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springdoc</groupId>
-           <artifactId>springdoc-openapi-ui</artifactId>
+           <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>${springdoc.version}</version>
            <scope>provided</scope>
        </dependency>
    </dependencies>
</project>
```

### Update Spring Cloud version for OpenFeign

```diff
<project>
    <properties>
-       <spring-cloud.version>2021.0.4</spring-cloud.version>
+       <spring-cloud.version>2023.0.5</spring-cloud.version>
    </properties>
    <dependencies>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-openfeign</artifactId>
       </dependency>
    </dependencies>
</project>
```

### Update Hibernate JPA Modelgen version

```diff
<project>
    <properties>
-       <hibernate-jpamodelgen.version>5.6.9.Final</hibernate-jpamodelgen.version>
+       <hibernate-jpamodelgen.version>6.2.9.Final</hibernate-jpamodelgen.version>
    </properties>
</project>
```

### Update HttpClient for RestTemplate

```diff
<project>
    <dependencies>
        <dependency>
-           <groupId>org.apache.httpcomponents</groupId>
-           <artifactId>httpclient</artifactId>
+           <groupId>org.apache.httpcomponents.client5</groupId>
+           <artifactId>httpclient5</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

### Update CMS Spring Boot Starter version

```diff
<project>
    <properties>
-       <cms-spring-boot-starter.version>1.0.1</cms-spring-boot-starter.version>
+       <ha-spring-boot-starter.version>3.1.1</ha-spring-boot-starter.version>
    </properties>
    <dependency>
-       <groupId>hk.org.ha.cms</groupId>
-       <artifactId>cms-spring-boot-starter</artifactId>
-       <version>${cms-spring-boot-starter.version}</version>
+       <groupId>hk.org.ha</groupId>
+       <artifactId>ha-spring-boot-starter</artifactId>
    </dependency>

    <dependencyManagement>
        <dependencies>
+           <dependency>
+               <groupId>hk.org.ha</groupId>
+               <artifactId>ha-spring-boot-starter</artifactId>
+               <version>${ha-spring-boot-starter.version}</version>
+               <type>pom</type>
+               <scope>import</scope>
+           </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

> Please refer to [this page](https://hagithub.home/CDRA/workflow-template/blob/main/doc/artifactory-setup.md#access-chassis-dependencies-and-libraries) to request CDC3 to setup `chassis` linkage to your repo.

### Update Security Framework to remove Keycloak adapter

Keycloak adapter - Policy Enforcer doesn't support Spring Boot 3, product team can refer the following steps for migrating to the HA Security framework - **ha-spring-boot-starter-security**.

1. Update POM dependency
1. Update application.yaml
1. Refactor the package of @Resource, @Scopes annotations to hk.org.ha.authz.security.annotation
1. Refactor SecurityContext to HaSecurityContext
1. Implement ClientResolver Interface
1. Implement the PermissionController

#### Update dependencies

```diff
    </properties>
-        <keycloak-adapter.version>18.0.1</keycloak-adapter.version>
    </properties>

    <dependencies>
        ...
-        <dependency>
-            <groupId>org.keycloak</groupId>
-            <artifactId>keycloak-spring-boot-starter</artifactId>
-        </dependency>
+       <dependency>
+           <groupId>hk.org.ha</groupId>
+           <artifactId>ha-spring-boot-starter-security</artifactId>
+       </dependency>
        ...
    <dependencies>

    <dependencyManagement>
        <dependencies>
-            <dependency>
-                <groupId>org.keycloak.bom</groupId>
-                <artifactId>keycloak-adapter-bom</artifactId>
-                <version>${keycloak-adapter.version}</version>
-                <type>pom</type>
-                <scope>import</scope>
-            </dependency>
            ...
        </dependencies>
    </dependencyManagement>

```

#### Update security config

Remove those keycloak related config from application.yml and add security config.

```diff
-client:
-  credentials: '{"ris":"xxxxx"}'
-
-keycloak:
-  enabled: true
-  ssl-required: external
-  auth-server-url: http://<SAM3 Host>/auth
-  realm: ris
-  ...
-  securityConstraints[1]:
-    securityCollections[0]:
-      name: public
-      ...

+spring:
+  security:
+    oauth2:
+      resourceserver:
+        jwt:
+          issuer-uri: http://<SAM3 Host>/auth/realms/ris
+          jwk-set-uri: http://<SAM3 Host>/auth/realms/ris/protocol/openid-connect/certs
+
+security:
+  auth-server-uri: http://<SAM3 Host>/auth/realms/ris
+  client:
+    credentials: >
+      [
+        {"clientId":"<profile code>",     "clientSecret":"<client secret>"}
+      ]
```

#### Update annotation packages

Refactor the framework package of Resource and Scopes

```diff
-import hk.org.ha.cms.auth.annotation.Resource;
-import hk.org.ha.cms.auth.annotation.Scopes;
+import hk.org.ha.authz.security.annotation.Resource;
+import hk.org.ha.authz.security.annotation.Scopes;
```

#### Update SecurityContext to HaRequestContext

```diff
-import hk.org.ha.cms.auth.context.SecurityContext;
-import hk.org.ha.cms.auth.context.SecurityContextHolder;
+import hk.org.ha.authz.security.context.HaRequestContext;
+import hk.org.ha.security.context.RequestContextHolderHelper;
```

#### Implement ClientResolver interface

Implement the ClientResolver for resolve the Profile Code

```diff
-public class ClientResolver extends AbstractClientResolver {
-    ...
-}
+public class XxxClientResolver implements ClientResolver {
+    ...
+}
```

#### Implement PermissionController

Controller for retrieving user permission list

```java

...
import hk.org.ha.authz.security.service.AuthorizationService;
import hk.org.ha.authz.security.annotation.Resource;
import hk.org.ha.authz.security.annotation.Scopes;

@RestController
@RequestMapping(name = "Authorization")
@AllArgsConstructor
@ConditionalOnProperty(name = "security.enabled", havingValue = "true", matchIfMissing = true)
@Resource("permission")
public class PermissionController {

    private final AuthorizationService authorizationService;

    @GetMapping(path = "/v1/permission", produces = MediaType.APPLICATION_JSON_VALUE)
    @Scopes("read")
    public List<String> getPermission() {
        return authorizationService.getPermissionList();
    }
}

```

Response example

```json
["uamUserMaint.read", "uamUserMaint.update", "permission.read"]
```

### Update CMS Spring Boot Starter Mybatis version

```diff
<project>
    <properties>
-       <cms-spring-boot-starter-mybatis.version>1.0.0</cms-spring-boot-starter-mybatis.version>
    </properties>
    <dependency>
-       <groupId>hk.org.ha.cms</groupId>
-       <artifactId>cms-spring-boot-starter-mybatis</artifactId>
+       <groupId>hk.org.ha</groupId>
+       <artifactId>ha-spring-boot-starter-migrate</artifactId>
    </dependency>
</project>
```

## Resolve deprecated features

### Migrate Spring Cloud Sleuth to Micrometer Tracing

Spring Cloud Sleuth will not work with Spring Boot 3.x onward. Please see the current [release notes](https://docs.spring.io/spring-cloud-sleuth/docs/current-SNAPSHOT/reference/html). All you need to do is make the following updates

```diff
<project>
    <properties>
+       <micrometer-tracing.version>1.3.3</micrometer-tracing.version>
    </properties>
    <dependencies>
-       <dependency>
-           <groupId>org.springframework.cloud</groupId>
-           <artifactId>spring-cloud-starter-sleuth</artifactId>
-       </dependency>
+       <dependency>
+           <groupId>org.springframework.boot</groupId>
+           <artifactId>spring-boot-starter-actuator</artifactId>
+       </dependency>
+       <dependency>
+           <groupId>io.micrometer</groupId>
+           <artifactId>micrometer-tracing-bridge-brave</artifactId>
+       </dependency>
+       <dependency>
+           <groupId>io.github.openfeign</groupId>
+           <artifactId>feign-micrometer</artifactId>
+       </dependency>
    </dependencies>
    <dependencyManagement>
        <dependencies>
+           <dependency>
+               <groupId>io.micrometer</groupId>
+               <artifactId>micrometer-tracing-bom</artifactId>
+               <version>${micrometer-tracing.version}</version>
+               <type>pom</type>
+               <scope>import</scope>
+           </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

> Reference: https://spring.io/blog/2022/10/12/observability-with-spring-boot-3#webmvc-server-setup.

## Review configuration changes

### Remove useless config

All of those configurations will be automatically obtained from environment variables.

```diff
-system:
- project-code: cmschassis
- app-name: @project.name@
- pod-name: ${KUBERNETES_POD_NAME:@project.name@}
```

The mybatis migrations configurations are no longer needed as the default has been updated.

```diff
-mybatis.migrations:
- enabled: false
- path: classpath:dbmigrate\scripts
```

### Update redis config changes

The properties prefix is now `spring.data.redis` instead of `spring.redis`.

```diff
spring:
- redis:
-   host: localhost
-   port: 6379
-   timeout: 2000ms
+ data:
+   redis:
+     host: localhost
+     port: 6379
+     timeout: 2000ms
```

### Update openfeign config changes

The properties prefix is now `spring.cloud.openfeign.client` instead of `feign.client`.

```diff
-feign:
- client:
-   config:
-     default:
-       connectTimeout: 5000
-       readTimeout: 5000
-       loggerLevel: full
spring:
+ cloud:
+   openfeign:
+     client:
+       config:
+         default:
+           connectTimeout: 5000
+           readTimeout: 5000
+           loggerLevel: full
```

## Handle breaking changes

### Upgrade to Jakarta EE

Spring Boot 3.0 has upgraded to the version that is included in Jakarta EE 10. Therefore the following imports has been changed:

- from `javax.activation` to `jakarta.activation`
- from `javax.annotation` to `jakarta.annotation`
- from `javax.el` to `jakarta.el`
- from `javax.inject` to `jakarta.inject`
- from `javax.persistence`to `jakarta.persistence`
- from `javax.security` to `jakarta.security`
- from `javax.servlet` to `jakarta.servlet`
- from `javax.transaction` to `jakarta.transaction`
- from `javax.validation` to `jakarta.validation`
- from `javax.websocket` to `jakarta.websocket`
- from `javax.xml` to `jakarta.xml`

To fix all occurrences at once, you can simply search for the `import javax` pattern in your source code and replace it with `import jakarta`.

### Upgrade CMS Spring Boot Starter

`CMS Spring Boot Starter` has been renamed to [`HA Spring Boot Starter`](https://hagithub.ha.org.hk/CHASSIS/ha-spring-boot-starter). Therefore the following imports has been changed:

- from `hk.org.ha.cms.web` to `hk.org.ha.web`
- from `hk.org.ha.cms.log` to `hk.org.ha.log`
- from `hk.org.ha.cms.util` to `hk.org.ha.util`
- from `hk.org.ha.cms.crypto` to `hk.org.ha.crypto`

To fix all occurrences at once, you can simply search for the `import hk.org.ha.cms.` pattern in your source code and replace it with `import hk.org.ha.`.

## Update third-party libraries

Check whether any third-party libraries or frameworks you're using in your project have specific requirements or compatibility issues with Spring Boot 3. Update these libraries to their latest versions that are compatible with Spring Boot 3.

The following command will help you to upgrade all your version properties in `pom.xml` at once.

```sh
mvnw versions:update-properties
```

## Run tests and perform integration testing

After making the necessary code changes and updates, run your project's test suite to ensure that everything still works as expected. Additionally, perform integration testing to validate the behavior of your application with the updated Spring Boot 3 dependencies.

## Deploy and monitor

Once you're confident that your application is working correctly with Spring Boot 3, deploy it to your development or staging environment. Monitor your application's behavior closely to identify any unexpected issues or performance changes introduced by the upgrade.

## Iterate and refine

Keep an eye on the Spring Boot community, official documentation, and release notes for any subsequent updates or bug fixes related to Spring Boot 3. Iterate on your codebase and configuration as needed to take advantage of new features, improve performance, or address any issues that arise.
