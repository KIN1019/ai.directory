---
title: CMS DHPAI Swagger OpenAPI Springboot Generator Instructions
description: |
  Set up complete Swagger/OpenAPI for a Spring Boot 3.x application and generate an OpenAPI 3.0 YAML specification dynamically. Includes dependency setup (`springdoc-openapi`), `SwaggerConfig`, `application.yaml` settings, DTO and controller annotation guidance, and options for runtime/build-time/CI YAML export.
tags: [dhpai, spring-boot, openapi, swagger, springdoc, java]
---

# Prompt: Set Up Complete Swagger/OpenAPI for Any Spring Boot 3.x Application

I need to set up **complete Swagger/OpenAPI documentation** for a **Spring Boot 3.x** application from scratch, **and generate/export an OpenAPI 3.0 specification in YAML format** (not just JSON), similar in structure and quality to well-formed specs like `cms-aeis-eresus-svc-1-0-0_v2.yaml`.

**Project Context (fill in before you start):**

- Spring Boot Version: `3.x` (e.g., 3.2.x or 3.3.x — specify exact version)
- Build Tool: `Maven` or `Gradle` (specify which one you’re using)
- Packaging: Standard Spring Boot JAR application
- Goal: Generate **comprehensive API documentation** (all controllers + DTOs), with **fully resolved nested DTO schemas** and **clear examples**, and produce a **clean, reusable OpenAPI 3.0 YAML spec**.

---

## Requirements

### 1. Dependency Setup

- Add the **springdoc-openapi** dependency for Spring Web MVC + Swagger UI:
  - Maven: `springdoc-openapi-starter-webmvc-ui` (version `2.x`, compatible with Spring Boot 3.x)
  - Or Gradle equivalent
- Ensure:
  - The project compiles without dependency conflicts.
  - The Swagger UI endpoint (e.g. `/swagger-ui.html` or `/swagger-ui/index.html`) is accessible once the app is running.

---

### 2. Core OpenAPI Configuration (`SwaggerConfig`)

Create a configuration class (e.g., `SwaggerConfig.java`) in an appropriate `config` package.

The configuration should include:

- An `@Configuration` class with:
  - An `OpenAPI` bean defining:
    - API title, version, description
    - Contact information
    - License (if applicable)
  - A component/bean that sets **custom global responses** (e.g., standardized 404 and 500 responses) for all operations.
  - An `OpenApiCustomizer` (or equivalent) to ensure **recursive schema resolution**, so nested DTOs and inner classes are fully expanded in the schema.
  - (Optional) An `OperationCustomizer` to apply operation-level customizations (e.g., tags, summaries, default responses).

Behavioral requirements:

- Nested DTOs and static inner classes must **not** appear as empty objects.
- All nested properties should be visible and documented in the generated OpenAPI schema.

---

### 3. Application Configuration (`application.yaml` or `application.properties`)

In application configuration (YAML preferred; properties also acceptable):

- Enable and configure Springdoc:

  Minimal required properties (YAML form; adapt to properties format if needed):

  ```yaml
  springdoc:
    api-docs:
      path: /v3/api-docs
      enabled: true
    swagger-ui:
      enabled: true
      path: /swagger-ui.html        # Or preferred UI path
      operations-sorter: method
      tags-sorter: alpha
      display-operation-id: false   # Set to false if operation IDs wrap awkwardly
    use-fqn: true                   # Use fully qualified class names in schemas
    resolve-fully: true             # Recursively resolve all nested schemas
    default-flat-param-object: true # Flatten complex parameter objects
    cache:
      disabled: true                # Disable cache in development
  ```

- If needed, allow for:
  - Custom CSS (e.g., `swagger-custom.css`)
  - Custom JavaScript (e.g., `swagger-custom.js`)
  - Custom Swagger UI path

---

### 4. DTO / Model Enhancement

For **all DTOs** (request/response objects, including nested and static inner classes):

- Add class-level `@Schema` annotations:
  - `name` (if needed)
  - `description` with clear, domain-specific explanation

- For **every field** in each DTO:

  - Add `@Schema` with:
    - `description = "..."` — concise but meaningful
    - `example = "..."` — realistic sample values

- Ensure:
  - Nested objects (e.g., domain-specific sub-entities) are documented.
  - Collections (e.g., `List<SomeDto>`) have well-documented element types.
  - Validation constraints (e.g., `@NotNull`, `@Size`) use **Jakarta** imports (`jakarta.validation.*`), not `javax`.

Target behavior:

- The generated OpenAPI should include **all DTOs** in the Schemas section.
- Complex nested structures should be fully expanded with all their properties.
- Aim for broad coverage so that every field is documented.

---

### 5. Controller Enhancement

For all REST controllers:

- Use `@Operation` (from `io.swagger.v3.oas.annotations`) to document each endpoint:
  - `summary`
  - `description`
  - (Optionally) `tags`, `operationId`, and response descriptions.

- For request bodies:
  - Use `@RequestBody` (Spring or Swagger annotation, as appropriate) with a description.
  - Ensure DTOs used as request/response bodies are the annotated ones from step 4.

- For responses:
  - Where needed, use `@ApiResponse` / `@ApiResponses` to describe status codes and payloads.
  - Ensure generic wrappers (e.g., `ResponseEntity<SomeDto>`) are properly documented.

Goal:

- Each REST endpoint should have:
  - Clear purpose and behavior description.
  - Well-documented input and output payloads.
  - Proper use of HTTP status codes documented in the OpenAPI spec.

---

### 6. Build, Run, and Verification

Using the project’s chosen build tool:

- Build (example):
  - Maven: `mvn clean package -DskipTests`
  - Gradle: `./gradlew clean build -x test`

- Run (example):
  - `java -jar target/[your-app].jar` (Maven default output)
  - Or the equivalent for your build setup

- After startup, verify:

  - OpenAPI JSON at: `http://localhost:[port]/v3/api-docs`
  - Swagger UI at: `http://localhost:[port]/swagger-ui.html` (or configured UI path)

Validation checklist:

- All controllers appear under correct tags.
- All DTOs are present under **Schemas**.
- Nested DTOs and static inner classes are **fully expanded**, not empty objects.
- `@Schema` descriptions and examples display as expected.
- Global 404/500 responses appear where configured.
- No compilation/runtime errors related to Jakarta vs javax imports.

---

### 7. YAML OpenAPI Specification Generation (Key New Requirement)

The OpenAPI 3.0 YAML spec must be **generated dynamically** from the live Swagger/Springdoc metadata, **not manually written in the code**. This ensures the YAML stays in sync with actual APIs as they evolve.

#### 7a. Dynamic YAML Generation Approaches

Choose **one or more** of the following to bind YAML generation to the Swagger lifecycle:

**Option A: Runtime YAML Export (Recommended for Development)**

- At application startup or via a scheduled task, consume the `/v3/api-docs` JSON endpoint.
- Convert JSON to YAML and write to `src/main/resources/static/api-spec.yaml` (or a configured output path).
- Example using a Spring `@PostConstruct` bean or scheduled task:
  ```java
  @Component
  public class OpenApiYamlExporter {
      @Autowired
      private RestTemplate restTemplate;
      
      @PostConstruct
      public void exportOpenApiToYaml() {
          String jsonSpec = restTemplate.getForObject("http://localhost:[port]/v3/api-docs", String.class);
          String yamlSpec = convertJsonToYaml(jsonSpec);
          writeYamlToFile(yamlSpec, "target/openapi-spec.yaml");
      }
  }
  ```
- The YAML is automatically regenerated each time the app starts, staying in sync with live code.
- Expose the YAML via a new endpoint (e.g., `/v3/api-docs.yaml`) or static resource.

**Option B: Maven/Gradle Build-Time Generation (Recommended for CI/CD)**

- Use a plugin to extract and convert the JSON spec during the build phase:
  - **Maven**: `org.springdoc:springdoc-openapi-maven-plugin` (converts `/v3/api-docs` to YAML at build time).
  - **Gradle**: Similar plugin or custom task to invoke Springdoc's JSON endpoint and convert to YAML.
- The YAML artifact is generated once per build and included in the deployable JAR or separately archived.
- Example Maven POM snippet:
  ```xml
  <plugin>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-maven-plugin</artifactId>
      <version>1.4</version>
      <executions>
          <execution>
              <phase>package</phase>
              <goals>
                  <goal>generate</goal>
              </goals>
              <configuration>
                  <apiDocsUrl>http://localhost:[port]/v3/api-docs</apiDocsUrl>
                  <outputFileName>openapi-spec.yaml</outputFileName>
                  <outputDir>${project.basedir}/target</outputDir>
              </configuration>
          </execution>
      </executions>
  </plugin>
  ```

**Option C: Post-Build / CI Script (Flexible)**

- After the JAR is built, run the app momentarily (or in a Docker container).
- Use a script (bash, Python, PowerShell) to:
  1. Start the Spring Boot app (e.g., `java -jar target/app.jar`).
  2. Wait for startup (`curl --retry` to `/v3/api-docs`).
  3. Download JSON and convert to YAML using a tool like `yq` (available on most CI/CD platforms).
  4. Stop the app and archive the YAML spec.
- Example PowerShell snippet:
  ```powershell
  java -jar target/app.jar &
  Start-Sleep -Seconds 5
  $json = Invoke-WebRequest -Uri "http://localhost:[port]/v3/api-docs" | Select-Object -ExpandProperty Content
  yq -P eval -r '.' -o yaml - <<< $json > openapi-spec.yaml
  ```

---

#### 7b. YAML Output Characteristics

The dynamically generated YAML spec must:

- Be structurally similar in quality and style to well-defined specs like `sample-api-docs-openapi.yaml`, with:
  - Top-level `openapi: 3.0.0`, `info`, `servers`, `paths`, and `components` sections.
  - Clear use of `tags`, `operationId`, `summary`, `description` for each endpoint.
  - Request/response bodies referencing DTO models via `$ref` under `components.schemas`.
  - Examples under `components.examples` and/or inline `examples` for responses where appropriate.
- Represent **all APIs** of the Spring Boot application, including:
  - All request/response models under `components.schemas`.
  - All endpoints under `paths`, grouped by logical tags.
  - 2xx and 5xx (or applicable) responses with correct schemas.
- Be valid OpenAPI 3.0 YAML that can be:
  - Served statically (e.g., `/api-spec.yaml` or `/v3/api-docs.yaml`).
  - Used by API tools (Postman, API Gateway configurations, CI/CD pipelines).
  - Versioned in source control or artifact repositories.

---

#### 7c. Integration Points

- **Swagger UI**: Optionally configure Springdoc to serve the YAML spec alongside JSON:
  ```yaml
  springdoc:
    swagger-ui:
      urls:
        - name: "API (JSON)"
          url: "/v3/api-docs"
        - name: "API (YAML)"
          url: "/v3/api-docs.yaml"
  ```
- **Documentation / Deployment**: Include the generated YAML in build artifacts, README, or API gateway configs.
- **Validation**: Validate the YAML using tools like `openapi-generator` or `swagger-cli` during CI/CD.

---

### 8. UI/UX Adjustments (Optional)

- Adjust Swagger UI behavior via Springdoc properties:
  - Hide operation IDs if they’re too long: `display-operation-id: false`.
  - Customize sort orders: `operations-sorter`, `tags-sorter`.

- Optional customization:
  - Add and wire up custom CSS (e.g., `swagger-custom.css`) for branding or layout tweaks.
  - Add and wire up custom JS (e.g., `swagger-custom.js`) for UI behavior.

---

### 9. Final Deliverables

By the end, produce:

1. A complete `SwaggerConfig` (or equivalent config) class with:
   - `OpenAPI` bean for metadata
   - Global response configuration
   - Recursive schema resolution (nested DTOs fully resolved)
   - Optional operation customization

2. Updated `application.yaml` / `application.properties` with:
   - All relevant `springdoc` configuration
   - Swagger UI path and options

3. Updated DTOs:
   - Class-level and field-level `@Schema` annotations across all request/response models.
   - Proper usage of **Jakarta** imports (`jakarta.validation.*`).

4. Updated controllers:
   - `@Operation`, `@ApiResponse(s)`, and `@RequestBody` annotations for all endpoints.

5. A running Spring Boot 3.x application with:
   - A working Swagger UI endpoint.
   - Fully documented APIs and schemas.

6. **An OpenAPI 3.0 YAML specification** that is:
   - **Generated dynamically** from the live Swagger/Springdoc metadata (not hand-written).
   - Tied to the build/startup lifecycle using one of the approaches in **Section 7a** (Runtime Export, Maven/Gradle Plugin, or CI Script).
   - Structurally equivalent to `cms-aeis-eresus-svc-1-0-0_v2.yaml`.
   - Served or exported as a static artifact (e.g., `/v3/api-docs.yaml` or `target/openapi-spec.yaml`).
   - Automatically updated whenever the code (controllers, DTOs, annotations) changes.

---

### Notes / Constraints

- Must be compatible with **Spring Boot 3.x** and **Jakarta** namespaces (no `javax.validation`).
- Use **springdoc-openapi 2.x** (which is aligned with Spring Boot 3.x).
- Emphasis is on:
  - Correct configuration
  - Full schema resolution for nested models
  - Rich, domain-specific documentation and examples.
  - A high-quality **YAML** OpenAPI spec, not only JSON.
