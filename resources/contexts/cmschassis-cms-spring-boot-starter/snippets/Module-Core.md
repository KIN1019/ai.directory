# HA Spring Boot Starter Core

The HA Spring Boot Starter Core is a collection of helper libraries designed to handle common tasks, including logging, exception handling and encryption.

## Dependencies and setup

```xml
<dependency>
    <groupId>hk.org.ha</groupId>
    <artifactId>ha-spring-boot-starter-core</artifactId>
</dependency>
```

## Exception Handling

### Built-in RESTful exceptions

A collection of built-in RESTful exceptions is available for you to throw at any time from your Spring Boot RestController.

| Name        | Status Code | Exception Class                                  |
| :---------- | :---------- | :----------------------------------------------- |
| Bad Request | 400         | hk.org.ha.web.exception.impl.BadRequestException |
| Forbidden   | 403         | hk.org.ha.web.exception.impl.ForbiddenException  |
| Not Found   | 404         | hk.org.ha.web.exception.impl.NotFoundException   |
| Conflict    | 409         | hk.org.ha.web.exception.impl.ConflictException   |

### Automatic exception handling

Typically, exceptions thrown by libraries like JPA or the Java Validation framework (JSR-380) need to be wrapped with appropriate HTTP response statuses. Now, all of the following exceptions will be handled automatically for you.

| Exception Class                                              | Response As | Status Code | Remark                |
| ------------------------------------------------------------ | ----------- | ----------- | --------------------- |
| java.lang.IllegalArgumentException                           | Bad Request | 400         |                       |
| javax.validation.ValidationException                         | Bad Request | 400         | JSR-380               |
| org.springframework.web.bind.MethodArgumentNotValidException | Bad Request | 400         | Spring Validator      |
| com.fasterxml.jackson.databind.exc.InvalidFormatException    | Bad Request | 400         | Incorrect JSON Format |
| org.hibernate.StaleObjectStateException                      | Conflict    | 409         | JPA Optimistic lock   |
| org.springframework.dao.ConcurrencyFailureException          | Conflict    | 409         | JPA Optimistic lock   |

### Generic error format

All RESTful exceptions will be responded in a generic error format.

| Name       | Data Type    | Description        |
| :--------- | :----------- | :----------------- |
| statusCode | Numeric      | HTTP status code   |
| message    | String Array | Error message(s)   |
| error      | String       | HTTP error message |

### Sample usage

Just throw the provided RESTful Exception under your Spring Boot RestController.

```java
throw new BadRequestException("Case Number is in wrong format");
```

Then the following JSON response will be received on your RESTful client.

```json
"HTTP/1.1 400 Bad Request"
{
  "statusCode": 400,
  "message": ["Case Number is in wrong format"],
  "error": "Bad Request",
  // ...
}
```

## Logging

Provide a common logging facility for both system and audit logs. Log outputs are written into log files, and all entries are schema-compatible for delivery to Centralized Logging and Analytics Platform (CLAP).

### Log level

The log levels allow you to control the verbosity of your application's logging output. By setting the appropriate log level, you can determine which types of log messages are recorded and displayed.

Log levels in order of importance, from highest to lowest:

| Log Level | Description                                                                                       |
| --------- | ------------------------------------------------------------------------------------------------- |
| AUDIT     | For audit purpose to record who do what at when.                                                  |
| CRITICAL  | the most severe log messages. It indicates that an unexpected or critical error has occurred.     |
| WARN      | potentially harmful or unexpected situations that may lead to errors or issues in the future.     |
| INFO      | provides general information about the application's execution.                                   |
| DEBUG     | provides detailed information about the application's internal processes and state.               |
| TRACE     | most detailed log messages. It provides extremely fine-grained information about the application. |

> In production environments, it is common to set the log level to a higher level (e.g., INFO or WARN) to avoid excessive log output and performance impact.

### Write logs by using Slf4J

SLF4J (Simple Logging Facade for Java) is a powerful logging framework that offers a straightforward and unified logging API for Java applications. By [enabling Lombok](Support-Lombok), you can further streamline the process of writing log messages, making it an advantageous addition to your development stack.

To enable SLF4J logging in your class, simply annotate it with `@Slf4j`, and use the logger to log an message directly.

```java
package hk.org.ha.sample;

import lombok.extern.slf4j.Slf4j;
import static hk.org.ha.log.LogMarker.CRITICAL;
import static hk.org.ha.log.LogMarker.AUDIT;

@Slf4j
public class MyClass {
    public void doSomething() {
        // simple
        log.info("Info Log Message...");
        log.warn("Warn Log Message...");

        // need to use Log Marker for critical
        log.error(CRITICAL, "Critical Log Message...");
        // critical with Throwable
        log.error(CRITICAL, "Critical Log Message...", ex);

        // need to use Log Marker for audit
        log.info(AUDIT, "Audit Log Message...");

        // with params
        log.info("Hello {}", "World");
        log.info("Successfully created user:{} in hospital:{}", "ctm123", "VH");

        // with exception
        try {
          // ...
        } catch (Exception e) {
          log.error(CRITICAL, "Unable to process", e);
        }
    }
}
```

The following messages will write to system console by default.

```log
2023-09-04 16:30:24.524  INFO 42668 --- [nio-8087-exec-1] h.o.h.c.sample.MyClass : Info Log Message...
2023-09-04 16:30:24.524  WARN 42668 --- [nio-8087-exec-1] h.o.h.c.sample.MyClass : Warn Log Message...
2023-09-04 16:30:24.526 CRITI 42668 --- [nio-8087-exec-1] h.o.h.c.sample.MyClass : Critical Log Message...
2023-09-04 16:30:24.530  INFO 42668 --- [nio-8087-exec-1] h.o.h.c.sample.MyClass : Hello World
2023-09-04 16:30:24.532  INFO 42668 --- [nio-8087-exec-1] h.o.h.c.sample.MyClass : Successfully created user:ctm123 in hospital:VH
```

> Notes that: The audit message will not write to console log, since it only allow write to JSON log file by design.

### Enable debug or trace log

The default log level for root logger is `info`, so you need to update the `application.yml` as follow to specifies the logging levels for different packages or classes.

```yml
logging:
  level:
    root: info
    "[hk.org.ha.sample]": debug
```

In the example above, the root logger is set to `info` level, meaning it will log messages at the `info` level and above. The package `hk.org.ha.sample` is set to `debug` level, so it will log messages at the `debug` level and above.

After that you can write the debug log and appear as normal.

```java
  if (log.isDebugEnabled()) {
    log.debug("Debug Log Message...");
  }
```

For further usage of the Slf4J logger please refer to [Slf4J User Manual](https://www.slf4j.org/manual.html)

### CLAP integration

Centralized Log Analysis Platform (CLAP) is to provide a comprehensive and efficient solution for aggregating, analyzing, and visualizing logs from various systems and applications within an organization.

#### Message structure

To facilitate log transfer to CLAP, the log messages are recorded in JSON format, allowing the Filebeat process to detect and transmit these files to CLAP.

| Fields         | Description                                                                                                 |                                          |  Remark  | ALS 4 Fields      |
| -------------- | ----------------------------------------------------------------------------------------------------------- | ---------------------------------------- | :------: | ----------------- |
| LOG_DTM        | Log date and time in milliseconds                                                                           | by logger                                |          |                   |
| LOG_TYPE       | CRITICAL, WARN, AUDIT, INFO, DEBUG, TRACE                                                                   | by logger                                |          |                   |
| HOSP_CODE      | Hospital code                                                                                               | header 'X-HA-HospCode'                   |  Rename  | LOCATION_CD       |
| DEVICE_ID      | Device ID                                                                                                   | header 'X-HA-DeviceId'                   |   Add    |                   |
| CLIENT_IP      | Workstation or device IP address                                                                            | header 'X-Forwarded-For' then remoteAddr |          |                   |
| CLIENT_NAME    | Workstation or device name                                                                                  | reverse lookup from client ip            |  Rename  | WORKSTATION_ID    |
| USER_CODE      | User login ID                                                                                               | from access token 'preferred username'   |  Rename  | USER_ID           |
| PROJECT_CODE   | Product profile code                                                                                        | from env. 'ALERT_PROJECT_CODE'           |          |                   |
| CORRELATION_ID | A unique ID that represents a user session within an application or system                                  | from access token 'session id'           |          |                   |
| TRACE_ID       | A unique ID to trace the flow of a request across multiple services within a distributed system.            | from micrometer tracing 'traceId'        |   Add    |                   |
| SPAN_ID        | A unique ID assigned to individual operations or events within a distributed trace.                         | from micrometer tracing 'spanId'         |   Add    |                   |
| CONTENT        | Message logged by the author                                                                                | by logger                                |          |                   |
| CAUSE          | Cause of Exception                                                                                          | by logger                                |   Add    |                   |
| SRC_CLASS      | Source class of the system log write                                                                        | by logger                                |          |                   |
| SRC_LINE_NO    | Line number to the Source class of the system log write                                                     | by logger                                |   Add    |                   |
| APP_NAME       | Application name                                                                                            | from env. 'APP_NAME'                     |          |                   |
| APP_VERSION    | Application version                                                                                         | from env. 'APP_VERSION'                  |   Add    |                   |
| REQUEST_PATH   | HTTP request method and path                                                                                | from http request                        |   Add    |                   |
| PROFILE_CODE   | UAM profile code                                                                                            | from UAM                                 |   Add    |                   |
| FUNCTION_CODE  | UAM function code                                                                                           | from UAM @Resource & @Scope              |   Add    |                   |
| ENTITY_NAME    | The entity class name                                                                                       | from JPA entity lifecycle                |   Add    |                   |
| ENTITY_EVENT   | The entity event (Create, Update or Delete)                                                                 | from JPA entity lifecycle                |   Add    |                   |
| K8S_NODE_NAME  | Kubernetes node name                                                                                        | from env. 'KUBERNETES_NODE_NAME'         |   Add    |                   |
| K8S_POD_NAME   | Kubernetes pod name                                                                                         | from env. 'KUBERNETES_POD_NAME'          |  Rename  | HOST_NAME         |
| K8S_NAMESPACE  | Kubernetes namespace                                                                                        | from env. 'KUBERNETES_NAMESPACE'         |   Add    |                   |
| LOCATION_CD    | Same as `HOSP_CODE` for backward compatibility                                                              | header 'X-HA-HospCode'                   |          |                   |
| WORKSTATION_ID | Same as `CLIENT_NAME` for backward compatibility                                                            | reverse lookup from client ip            |          |                   |
| USER_ID        | Same as `USER_CODE` for backward compatibility                                                              | from access token 'preferred username'   |          |                   |
| TRANSACTION_ID | Same as `TRACE_ID` for backward compatibility                                                               | from micrometer tracing 'traceId'        |          |                   |
| HOST_NAME      | Same as `K8S_POD_NAME` for backward compatibility                                                           | from env. 'KUBERNETES_POD_NAME'          |          |                   |
|                | Registered Function ID `(Audit only)`                                                                       | by custom fields                         | Optional | FUNCTION_ID       |
|                | Registered Operation ID `(Audit only)`                                                                      | by custom fields                         | Optional | OPERATION_ID      |
|                | HKID / Passport No                                                                                          | by custom fields                         | Optional | PATIENT_IDENTITY  |
|                | Patient Key, PMI No. Tokenized patient identifier                                                           | by custom fields                         | Optional | PATIENT_KEY       |
|                | Hospital Code / Service + Clinic of Patient                                                                 | by custom fields                         | Optional | PATIENT_LOCATION  |
|                | Case Number                                                                                                 | by custom fields                         | Optional | CASE_NO           |
|                | Registered Message ID                                                                                       | by custom fields                         | Optional | MESSAGE_ID        |
|                | Brief description of log as tips of what had happened                                                       | by custom fields                         | Optional | DESCRIPTION       |
|                | For storing sensitive data and JSON                                                                         | deprecated                               |  Remove  | ENCRYPTED_CONTENT |
|                | Hashed value of all fields                                                                                  | deprecated                               |  Remove  | HASH_VALUE        |
|                | Hashed value of the PATIENT_IDENTITY                                                                        | deprecated                               |  Remove  | HASH_VALUE_PATID  |
|                | A random AES key which encrypt above fields and is encrypted by RSA. Decrypt this key for field decryption. | deprecated                               |  Remove  | ENCRYPTED_KEY     |
|                | Indicate extra fields for encryption.                                                                       | deprecated                               |  Remove  | ENCRYPT_FIELDS    |

Sample log message:

```json
{
  "LOG_DTM": "2023-09-13T17:03:49.041+08:00",
  "LOG_TYPE": "INFO",
  "HOSP_CODE": "QEH",
  "DEVICE_ID": "fba98c1a-e1ae-4f63-94c7-30f02ed1ad0b",
  "CLIENT_IP": "160.68.35.21",
  "CLIENT_NAME": "ea3dev01",
  "USER_CODE": "ctm123",
  "PROJECT_CODE": "cmschassis",
  "CORRELATION_ID": "03e882d5-03f9-418b-8009-5e24bfde74dc",
  "TRACE_ID": "bb29e34227269aed",
  "SPAN_ID": "3deb8b00d78d56b8",
  "CONTENT": "createProduct CreateProductDto(code=W004, name=Washing Machine 4, price=1234.0, attributes=[electronics])",
  "CAUSE": "",
  "SRC_CLASS": "hk.org.ha.jss.controller.ProductController",
  "SRC_LINE_NO": "70",
  "APP_NAME": "jpa-svc-tutorial",
  "APP_VERSISON": "1.0.0",
  "REQUEST_PATH": "POST /product",
  "PROFILE_CODE": "ris-qeh",
  "FUNCTION_CODE": "product.create",
  "ENTITY_NAME": "",
  "ENTITY_EVENT": "",
  "K8S_NODE_NAME": "cldappvmctst12w.serverdev.hadev.org.hk",
  "K8S_POD_NAME": "jpa-svc-tutorial-848c57d9dd-bmq6v",
  "K8S_NAMESPACE": "cmschassis-dev",
  "LOCATION_CD": "QEH",
  "WORKSTATION_ID": "ea3dev01",
  "USER_ID": "ctm123",
  "TRANSACTION_ID": "bb29e34227269aed",
  "HOST_NAME": "jpa-svc-tutorial-848c57d9dd-bmq6v"
}
```

#### Log file path format

In order to transfer log files to CLAP, it is also necessary to write them in a specific file path format into a Kubernetes persistence volume that mounted into Hostpath.

**Configuation**

By default, the option to write log files is disabled. To enable logging information in JSON format for CLAP, you need to include the following configuration in `application.yml`.

```yml
app-log:
  file:
    path: /logs
  console:
    enabled: false

audit-log:
  file:
    path: /logs
```

> If you don't want the app-log to be printed to the console at all, you can set `app-log.console.enabled` to false (default is true).

The log file full path will be automatically generated for you using the `APP_NAME` and `KUBERNETES_POD_NAME` environment variables. and all the log messages will be written into those files.

**Format of application log**

Pattern: `[Hostpath PV Mount Point]/[Pod Name]/[App Name]-[yyyyMMdd]-[0|1]-als-app.log`

> Where: `0` is non-critical log and `1` is critical log.

```sh
${app-log.file.path}/${KUBERNETES_POD_NAME}/${APP_NAME}-%d{yyyyMMdd}-[0|1]-als-app.log
# example: /logs/jpa-svc-tutorial-69cb7c884c-swkg7/jpa-svc-tutorial-20230831-0-als-app.log
```

**Format of audit log**

Pattern: `[Hostpath PV Mount Point]/[Pod Name]/[App Name]-[yyyyMMdd]-als-aud.log`

```sh
${audit-log.file.path}/${KUBERNETES_POD_NAME}/${APP_NAME}-%d{yyyyMMdd}-als-aud.log
# example: /logs/jpa-svc-tutorial-69cb7c884c-swkg7/jpa-svc-tutorial-20230831-als-aud.log
```

> Both `APP_NAME` and `KUBERNETES_POD_NAME` environment variables should be pre-defined by k8s deployment config.
> For information please refer to http://itsc.home/SC4/Cloud/Cloud%20Wiki/EAPc1.0.0%20-%20EAP%20OpenJDK.aspx

### Automating audit logging

To automate the audit logging of JPA (Java Persistence API) entity updates, you can utilize the following approaches step by step.

1. Enable the audit log support by update the `application.yml`.

```yml
audit-log:
  file:
    path: /logs
```

2. Annotation your entity with `@EntityListeners(AuditLogListener.class)`.

Sample Class: `hk.org.ha.jss.entity.Order`

```java
package hk.org.ha.jss.entity;
...
import hk.org.ha.audit.AuditLogListener;

@Entity(name = "ordr")
@EntityListeners(AuditLogListener.class)
public class Order extends VersionEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "orderSeq")
    @SequenceGenerator(name = "orderSeq", sequenceName = "ordr_seq")
    private Long id;

    @ManyToOne
    @JoinColumn(nullable = false)
    private Customer customer;

    @Column(nullable = false)
    private RecordStatus status;

    @OneToMany(mappedBy = "order", fetch = FetchType.EAGER, cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("seq")
    private List<OrderItem> items;
}
```

Sample Class: `hk.org.ha.jss.entity.OrderItem`

```java
@Entity(name = "ordr_item")
public class OrderItem extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "orderItemSeq")
    @SequenceGenerator(name = "orderItemSeq", sequenceName = "ordr_item_seq")
    private Long id;

    @Column(nullable = false)
    private Integer seq;

    @Column(nullable = false)
    private Float quantity;

    @ManyToOne
    @JoinColumn(nullable = false, foreignKey = @ForeignKey(name = "ordr_item_product_ver_fk"))
    private ProductVer productVer;

    @JsonIgnore // <== Add this annotation to avoid circular reference during the serialization
    @ManyToOne
    @JoinColumn(nullable = false, name = "ordr_id", foreignKey = @ForeignKey(name = "ordr_item_order_fk"))
    private Order order;
}
```

The Spring Boot's `ObjectMappper` will be use to serialize your entity into the database, all the properties will be included during the serialization. Please be aware that you need to stop the circular reference from `OrderItem` to `Order` entity by adding the `@JsonIgnore` annotation.

> Beaware that don't annotate all your entities, you should only apply to the entities that is not transactional, the example here is just a demonstration of the usage

3. Automatic logging for any updates

As a result the following json data will be added into your JSON message `CONTENT` field. the entity name and entity lifecycle event will also be logged under `ENTITY_NAME` and `ENTITY_EVENT` columns accordingly.

```json
{
  "LOG_DTM": "2023-09-13T17:03:49.453+08:00",
  "LOG_TYPE": "AUDIT",
  "HOSP_CODE": "QEH",
  "DEVICE_ID": "fba98c1a-e1ae-4f63-94c7-30f02ed1ad0b",
  "CLIENT_IP": "160.68.35.21",
  "CLIENT_NAME": "ea3dev01",
  "USER_CODE": "ctm123",
  "PROJECT_CODE": "cmschassis",
  "SESSION_ID": "03e882d5-03f9-418b-8009-5e24bfde74dc",
  "TRACE_ID": "bb29e34227269aed",
  "SPAN_ID": "3deb8b00d78d56b8",
  "CONTENT": "{\"createDate\":\"2023-09-13T17:03:49.416+08:00\",\"updateDate\":\"2023-09-13T17:03:49.416+08:00\",\"createUser\":\"system\",\"updateUser\":\"system\",\"id\":102,\"name\":\"Washing Machine 4\",\"attributes\":[\"electronics\"],\"price\":1234.0,\"status\":\"Active\",\"ver\":1}",
  "CAUSE": "",
  "SRC_CLASS": "hk.org.ha.log.entity.listener.AuditLogListener",
  "SRC_LINE_NO": "46",
  "APP_NAME": "jpa-svc-tutorial",
  "APP_VERSISON": "1.0.0",
  "REQUEST_PATH": "POST /product",
  "PROFILE_CODE": "ris-qeh",
  "FUNCTION_CODE": "product.create",
  "ENTITY_NAME": "hk.org.ha.jss.entity.ProductVer",
  "ENTITY_EVENT": "Create",
  "K8S_NODE_NAME": "cldappvmctst12w.serverdev.hadev.org.hk",
  "K8S_POD_NAME": "jpa-svc-tutorial-848c57d9dd-bmq6v",
  "K8S_NAMESPACE": "cmschassis-dev",
  "LOCATION_CD": "QEH",
  "WORKSTATION_ID": "ea3dev01",
  "USER_ID": "ctm123",
  "TRANSACTION_ID": "bb29e34227269aed",
  "HOST_NAME": "jpa-svc-tutorial-848c57d9dd-bmq6v"
}
```

### Log custom fields

To facilitate the inclusion of custom fields in the JSON log message, it is necessary to create a `hk.org.ha.log.CustomFieldJsonProvider` class within your project. This class provides a way to expand your JSON log message by adding extra fields.

#### Custom field JSON provider

Here's an example version of the `hk.org.ha.log.CustomFieldJsonProvider` class which adds the `PATIENT_KEY`, `ENCRYPTED_HKID`, and `HASHED_HKID` custom fields.

```java
package hk.org.ha.log;

import java.io.IOException;

import org.slf4j.MDC;

import com.fasterxml.jackson.core.JsonGenerator;

import ch.qos.logback.core.spi.DeferredProcessingAware;
import net.logstash.logback.composite.AbstractJsonProvider;
import net.logstash.logback.composite.JsonWritingUtils;

public class CustomFieldJsonProvider<E extends DeferredProcessingAware> extends AbstractJsonProvider<E> {

    public static final String PATIENT_KEY = "PATIENT_KEY";
    public static final String ENCRYPTED_HKID = "ENCRYPTED_HKID";
    public static final String HASHED_HKID = "HASHED_HKID";

    @Override
    public void writeTo(JsonGenerator generator, E iLoggingEvent) throws IOException {
        JsonWritingUtils.writeStringField(generator, PATIENT_KEY, MDC.get(PATIENT_KEY));
        JsonWritingUtils.writeStringField(generator, ENCRYPTED_HKID, MDC.get(ENCRYPTED_HKID));
        JsonWritingUtils.writeStringField(generator, HASHED_HKID, MDC.get(HASHED_HKID));
    }
}
```

> You need to ensure that the package and class names match exactly to `hk.org.ha.log.CustomFieldJsonProvider` within your project.

#### Log custom field with MDC

If you are not familiar with MDC, please take a look at [this](https://www.baeldung.com/mdc-in-log4j-2-logback) first to get a better understanding of what MDC is.

MDC is useful but can lead to clunky code as every key-value pair must be cleared to prevent potential issues in multi-threaded scenarios. Please refer to [here](https://auto1.tech/functional-style-mdc/) for more explaination and example.

#### Introduce LogMDC

To address the drawbacks of MDC, LogMDC is introduced to implement the function-style logging of MDC. It captures all the keys and performs the `MDC.remove(key)` operation after logging execution.

Here is an example of its usage:

```java
import static hk.org.ha.log.CustomFieldJsonProvider.PATIENT_KEY;
import hk.org.ha.log.mdc.LogMDC;

@Slf4j
@Service
@AllArgsConstructor
public class PatientService {

  public void discharge(Patient patient) {
    // ...
    LogMDC.executor()
        .put(PATIENT_KEY, patient.getKey())
        .execute(() -> log.info("Patient discharged"));
  }
}
```

> The `LogMDC.executor()` method returns an instance of an executor that allows you to set MDC values for the current thread. The `execute()` method call executes a lambda or anonymous function that logs the message using the log object from the `@Slf4j` annotation.

**JSON log result**

```json
{
  "LOG_DTM": "2023-09-13T17:03:49.041+08:00",
  "LOG_TYPE": "INFO",
  // ...
  "CONTENT": "Patient discharged",
  "PATIENT_KEY": "1234567"
}
```

#### Encryption & hashing on custom field

Logging encrypted and hashed fields is essentially the same; you simply need to utilize the provided `Cipher` and `Hasher` component.

```java
import static hk.org.ha.log.CustomFieldJsonProvider.ENCRYPTED_HKID;
import static hk.org.ha.log.CustomFieldJsonProvider.HASHED_HKID;
import hk.org.ha.crypto.Cipher;
import hk.org.ha.crypto.Hasher;
import hk.org.ha.log.mdc.LogMDC;

@Slf4j
@Service
@AllArgsConstructor
public class PatientService {

  private final Cipher cipher;
  private final Hasher hasher;

  public void discharge(Patient patient) {
    // ...
    LogMDC.executor()
        .put(ENCRYPTED_HKID, cipher.encrypt(patient.getHkid()))
        .put(HASHED_HKID, hasher.hash(patient.getHkid()))
        .execute(() -> log.error(AUDIT, "Patient discharged"));
  }
}
```

**JSON log result**

```json
{
  "LOG_DTM": "2023-09-13T17:03:49.041+08:00",
  "LOG_TYPE": "AUDIT",
  // ...
  "CONTENT": "Patient discharged",
  "ENCRYPTED_HKID": "lG3luriseM6aqB+4eeaNfbZFOYO3p9f5cmKt9+8BZfS30PU9PkUQop+/1/4WZGWv3rMFVxdFcJ0mRFY9jJKSuWNkGzwVmWGK65gofKdRa0CE9bNhrvWsZBa3tuBdCyimdYg59yspo08DKwcoH0K0pf2VVeJQs6n1d+tAuqMJoqqI+dHZDypcXMgtMbojQwAiu2GaSIgxKAN5Yc0ltN0pEQwWXBTIEfjFCqlAXxtwk0thz7lm4NesvUdet3N541UV7hjqh3jPsVKPpQvCNgnhlbtfQ06mLskoh9aFsIBbWDos8B3K3z2qhP4mKrKsBRdB06gSGC4WfAbyQ8B0xDRJQ==",
  "HASHED_HKID": "929e5a8c1d13206ef1159764a0386a5a79895d3d7aecbaa091c8dfeaf8f807f4"
}
```

## Encryption

The `Cipher` component is a powerful tool that facilitates encryption and decryption operations in various applications. It provides a convenient and secure way to protect sensitive data by transforming it into an unreadable format.

### Configuration

Under your `application.yml`.

```yml
cipher:
  keystore:
    path: <full-path-to-your-keystore.jks>
  key:
    alias: mykey
    algorithm: RSA
```

To utilize the `Cipher` component, it is necessary to generate your RSA key pair in the Java keystore format.

```sh
keytool -genkeypair -alias mykey -keyalg RSA -keysize 2048 -keystore secret-keystore.jks
```

If you only require the encryption function, please extract only the public key into a separate keystore, and keep the original for decryption later.

```sh
keytool -exportcert -alias mykey -file publickey.crt -keystore secret-keystore.jks
keytool -importcert -alias mykey -file publickey.crt -keystore keystore.jks -storepass changeit
rm publickey.crt
```

### Example usage

```java
import hk.org.ha.crypto.Cipher;

@RestController
@AllArgsConstructor
public class CipherController {

    private final Cipher cipher;

    @GetMapping("/encrypt")
    public String encrypt(@RequestParam String plaintext) {
        return cipher.encrypt(plaintext);
    }

    @GetMapping("/decrypt")
    public String decrypt(@RequestParam String ciphertext) {
        return cipher.decrypt(ciphertext);
    }
}
```

## Hashing

The `Hasher` component is a valuable tool used for generating hash values from data. It plays a crucial role in ensuring data integrity, verifying data integrity, and providing a layer of security in various applications.

### Configuration

Under your `application.yml`.

```yml
hasher:
  alglorithm: SHA-256
```

> you can change the alglorithm to `MD5` for shorter hash.

### Example usage

```java
import hk.org.ha.crypto.Hasher;

@RestController
@AllArgsConstructor
public class HasherController {

    private final Hasher hasher;

    @GetMapping("/hash")
    public String hash(@RequestParam String plaintext) {
        return hasher.hash(plaintext);
    }
}
```

## Automatic Enum Code Generation

The [Automatic Enum Code Generation](Support-Enum-Code-Generator) from Java's String Valued Enum to TypeScript file is a solution created to address the challenge of sharing Java Enum Classes with corresponding TypeScript types through a RESTful API.
