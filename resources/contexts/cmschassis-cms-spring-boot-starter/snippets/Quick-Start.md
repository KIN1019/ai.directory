# Quick Start

Here, we provide the simplest steps to create an empty project using Spring Initializr and also add the HA Spring Boot Starter dependencies for a quick start.

## Create an empty project

Setup an empty project using [Spring Initializr](https://start.spring.io/).

1. Select as a `Maven` Project and `Java` as Language.

2. Select Spring Boot version as `3.3.x`.

3. Update the Project Metadata Group as `hk.org.ha.cms`.

4. Update the Project Metadata Artifact as `example-svc`.

5. Update the Project Metadata Package name as `hk.org.ha.cms.example`.

6. Update the Project Metadata Java to version `17`.

7. Press `ADD DEPENDENCIES...` button to add the following dependency:
   - Spring Web
   - Spring Boot Actuator
   - Validation
   - Lombok
   - Spring Data JPA
   - H2 Database
   - OpenFeign

Press the `GENERATE` button to download an empty project template. Extract the zip folder to start editing.

## Adjust the Spring Framework version

```diff
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
-       <version>3.3.x<version>
+       <version>3.3.10</version>
        <relativePath/>
    </parent>
    ...
    <properties>
        <java.version>17</java.version>
-       <spring-cloud.version>2023.x.x</spring-cloud.version>
+       <spring-cloud.version>2023.0.5</spring-cloud.version>
        ...
    <properties>
</project>
```

## Add dependencies

Setup the [Maven Repository](Support-Maven-Repository) and update the `pom.xml` as follow.

```xml
<project>
    <properties>
        ...
        <micrometer-tracing.version>1.3.3</micrometer-tracing.version>
        <jacoco.version>0.8.12</jacoco.version>
        <springdoc.version>2.6.0</springdoc.version>
        <ha-spring-boot-starter.version>3.1.1</ha-spring-boot-starter.version>
    </properties>

    <dependencies>
        ...
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-tracing-bridge-brave</artifactId>
        </dependency>
        <dependency>
            <groupId>io.github.openfeign</groupId>
            <artifactId>feign-micrometer</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
            <version>${springdoc.version}</version>
        </dependency>
        <dependency>
            <groupId>hk.org.ha</groupId>
            <artifactId>ha-spring-boot-starter-core</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            ...
            <dependency>
                <groupId>io.micrometer</groupId>
                <artifactId>micrometer-tracing-bom</artifactId>
                <version>${micrometer-tracing.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>hk.org.ha</groupId>
                <artifactId>ha-spring-boot-starter</artifactId>
                <version>${ha-spring-boot-starter.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            ...
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                ...
                <executions>
                    <execution>
                        <id>build-info</id>
                        <goals>
                            <goal>build-info</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>${jacoco.version}</version>
                <executions>
                    <execution>
                        <id>default-prepare-agent</id>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>default-report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
<project>
```

## Add default properties

Rename `src/main/resources/application.properties` to `src/main/resources/application.yml`. Then Add the following:

```yml
# JPA support
spring:
  datasource:
    url: ${DATABASE_URL:jdbc:h2:mem:testdb;user=sa}
    hikari:
      connection-timeout: ${DATABASE_CONNECTION_TIMEOUT:5000}
      maximum-pool-size: ${DATABASE_MAXIMUM_POOL_SIZE:10}
  transaction:
    default-timeout: 35
  sql:
    init:
      mode: always
  jpa:
    defer-datasource-initialization: true
    show-sql: false
    hibernate:
      ddl-auto: create
    properties:
      hibernate:
        "[default_batch_fetch_size]": 20
  h2:
    console:
      enabled: true
      path: /console

# Header propagation
management:
  tracing:
    baggage:
      remote-fields:
        - authorization
        - x-ha-hospcode
        - x-ha-deviceid

# Logging
logging:
  level:
    "[hk.org.ha.cms.example]": ${LOG_LEVEL:info}
```

If you do not need `JPA support`, please remove the entire JPA section and add the following configuration to exclude autoconfiguration.

```yml
spring.autoconfigure.exclude:
  - org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration
  - org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration
  - org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration
```

## Add a health controller

Create the following file `src/main/java/hk/org/ha/cms/example/controller/HealthController.java`.

```java
package hk.org.ha.cms.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

    @GetMapping("/")
    public String check() {
        return "OK";
    }

    @GetMapping("/healthcheck")
    public String healthcheck() {
        return "healthy";
    }
}
```

## Add default confguration

1. Configure the JSON serializer (Jackson) to use the default timezone for ISO-8601 date format.

Create the following file `src/main/java/hk/org/ha/cms/example/config/JacksonConfig.java`.

```java
package hk.org.ha.cms.example.config;

import java.util.TimeZone;

import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JacksonConfig {

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jacksonObjectMapperCustomization() {
        return jacksonObjectMapperBuilder -> jacksonObjectMapperBuilder.timeZone(TimeZone.getDefault());
    }
}
```

2. Customize OpenAPI swagger to serve on root path.

Create the following file `src/main/java/hk/org/ha/cms/example/config/SwaggerConfig.java`.

```java
package hk.org.ha.cms.example.config;

import org.springframework.boot.info.BuildProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;

@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI customOpenAPI(BuildProperties buildProperties) {
        return new OpenAPI().info(new Info()
                .title(buildProperties.getName())
                .version(buildProperties.getVersion()))
                .addServersItem(new Server().url("/"));
    }
}
```

3. Add `@EnableFeignClients` annotation into your Spring Boot Application startup class.

```java
package hk.org.ha.cms.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class ExampleSvcApplication {

    public static void main(String[] args) {
        SpringApplication.run(ExampleSvcApplication.class, args);
    }
}
```

## Start the server

Start server with below command:

```bash
mvnw spring-boot:run
```

Goto http://localhost:8080 You should see the `OK` message.
