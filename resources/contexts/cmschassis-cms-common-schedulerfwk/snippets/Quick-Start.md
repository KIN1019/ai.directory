##   Quick Start
Here, we provide the simplest step to import the common scheduler library and also add the dependencies for a quick start

## Prerequisite
- Java 17 or higher
- Spring Boot 3.X or higher
- PostgreSQL Database with tables list in [Support DB DDL](https://hagithub.home/CMSCHASSIS/cms-common-schedulerfwk/wiki/Support-DB-DDL) 

##  Add dependencies
Setup the Maven Repository and update the `pom.xml` as follow
```xml
<project>
    <dependencies>
        ...
       <dependency>
            <groupId>hk.org.ha.cms</groupId>
            <artifactId>common-schedulerfwk</artifactId>
            <version>1.0.0</version>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
    </dependencies>

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
        </plugins>
    </build>
<project>
```
## Add default properties 
Rename `src/main/resources/application.properties` to `src/main/resources/application.yml`. Then Add the following:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://${POSTGRES_DATABASE_URL}
    username: ${POSTGRES_DATABASE_USERNAME}
    password: ${POSTGRES_DATABASE_URL}
    driver-class-name: org.postgresql.Driver
  hikari:
      minimum-idle: 1
      maximum-pool-size: ${DATABASE_MAXIMUM_POOL_SIZE:5}
      max-lifetime: 450000
  jpa:
    defer-datasource-initialization: true
    show-sql: false
    hibernate:
      ddl-auto: validate

app-log:
  file:
    path: /logs
  console:
    enabled: false

cms-scheduler:
  enabled: true
  schedule_name: ${input your scheduler name}
  # Pls fill in your schema name

  bppm_notify: true # True if you want to send BPPM Alert
  bppm_job_overdue: 300 # in seconds

  db_schema: <application_schema>   # Suggest to use product schema
  db_prefix: <prefix_for_table>     # Suggest to use product name

  # design by the team, default is 10
  # many I/O scheduling job, higher thread count
  # many CPU scheduling job, lower thread count
  thread_count: 20
```

## Sample Scheduling Spring Boot Project
Please refer this [link](https://hagithub.home/CMS/cms-common-schedulerfwk-sample) for sample scheduling project using the cms-common-schedulerfwk