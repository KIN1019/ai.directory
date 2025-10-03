# HA Spring Boot Starter Security

The HA Spring Boot Starter Security is based on Spring Security and it is extended to support SAM3 authorization.
When the **-security** module is included to application pom.xm, all endpoints are protected but excepts the public endpoints (health check and swagger-doc).

**Please note that if ONLY SAM3 authentication is required, product team can refer to [Spring Security](https://docs.spring.io/spring-security/reference/index.html) and following section.**

> SAM3 - Red Hat Single Sign-On (RHSSO) is enterprise variant of Open-source Keycloak
>
> - [RHSSO Reference](https://access.redhat.com/products/red-hat-single-sign-on/)
> - [Keycloak Reference](https://www.keycloak.org/)


## Dependencies and setup

```xml
<dependency>
    <groupId>hk.org.ha</groupId>
    <artifactId>ha-spring-boot-starter-security</artifactId>
</dependency>
```

## Authentication ONLY

### Prerequisite

1. SAM3 Realm is created (e.g. ris, lis, cms ...)

### Configuration

[Spring Security configuration](https://docs.spring.io/spring-security/reference/servlet/oauth2/resource-server/jwt.html)

**spring.security.oauth2.resourceserver.jwt.issuer-uri** - Url of JWT issuer for token validation e.g. SAM3 Host
**spring.security.oauth2.resourceserver.jwt.jwk-set-uri** - Url for JSON Web Key Sets

```yaml
# Config for Authentication ONLY
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://<SAM3 Host>/auth/realms/ris
          jwk-set-uri: http://<SAM3 Host>/auth/realms/ris/protocol/openid-connect/certs

security:
  enabled: true
  # set public read-only endpoint
  permit-get-url-patterns: /healthcheck
  # set public update endpoint
  permit-all-url-patterns: /v1/machine/register, /xxx
```

## Authentication & Authorization

### Prerequisite

1. SAM3 Realm is created (e.g. ris, lis, cms ...)
1. UAM Console integrated with SAM3 and initialized
1. UAM Profile is created (e.g. ris-kwh )

### Configuration

HA Security configuration for SAM3 Authorization

**security.client.credentials** - JSON array for Client Id with Client Secret that are created through UAM Console.
e.g. hospital based: ris-kwh, ris-qeh, ...


**security.auth-server-uri** - Url of OAuth Service e.g. SAM3 Host

```yaml
# Config for Authentication + Authorization
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://<SAM3 Host>/auth/realms/ris
          jwk-set-uri: http://<SAM3 Host>/auth/realms/ris/protocol/openid-connect/certs

security:
  auth-server-uri: http://<SAM3 Host>/auth/realms/ris
  client:
    credentials: |
      [
          {"clientId":"<profile code>", "clientSecret":"<client secret>"}           
      ]
```

### Implement Client Resolver

Client Resolver depends on the values presented in HTTP request header to dictate the profile code (that is the "Profile" defined in UAM)

Example header key: **X-HA-ProfileCode**
The react-app includes the above information (in request header) for calling the protected endpoint.
Server-side Security framework uses the client resolver to resolve the Profile Code for permission checking.

```java
import org.springframework.stereotype.Component;

import hk.org.ha.authz.security.resolver.ClientResolver;
import jakarta.servlet.http.HttpServletRequest;

@Component
public class DemoClientResolver implements ClientResolver {

    @Override
    public String getProfileCode(HttpServletRequest httpRequest) {
        return httpRequest.getHeader("X-HA-ProfileCode");
    }
}
```

### Protected API endpoints example

Suppose there is 2 permissions: **uamUserMaint.read** and **uamUserMaint.create** for 2 API endpoints.

The related controller can be decorated by **@Resource**, **@Scopes** for SAM3 authorization checking by security framework.

```java

...
import hk.org.ha.authz.security.annotation.Resource;
import hk.org.ha.authz.security.annotation.Scopes;

@RestController
@AllArgsConstructor
@Resource("uamUserMaint")
public class MemberController implements MemberApi {

    @Scopes({ "read" })
    @Override
    public UserDto getMember(String userCode) {
        ...
        return userDto;
    }

    @Scopes({ "create" })
    @PostMapping(path = "/v1/member/{userCode}")
    public UserDto createMember(@RequestBody UserDto input) {
        ...
        return userDto;
    }
}

```

## Obtaining information of current user

Get User Code in controller as method parameter.

```java
@Resource("user")
@RestController
@RequestMapping(value = "v1/user", name = "User", produces = MediaType.APPLICATION_JSON_VALUE)
public class UserController {
    ...
    @Scopes({ "read" })
    @GetMapping(path = "{id}")
    public Map<String, Object> getUser(@PathVariable Long id, JwtAuthenticationToken principal) {
      String userCode = principal.getName(); //e.g. ctm123
      ...
    }
}
```
