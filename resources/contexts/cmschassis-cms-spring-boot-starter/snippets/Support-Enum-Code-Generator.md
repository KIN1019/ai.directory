# Enum Code Generator

The Automatic Code Generation from Java's String Valued Enum to TypeScript file is a solution created to address the challenge of sharing Java Enum Classes with corresponding TypeScript types through a RESTful API.

The Enum Code Generator is designed to overcome this limitation by automatically generating TypeScript code from Java Enums. By utilizing this code generation approach, developers can seamlessly synchronize Enum classes between Java and TypeScript, ensuring consistency and reducing manual effort in maintaining shared Enum values across different programming languages.

## Implement a RESTful Enum endpoint on Spring Boot

### StringValuedEnum utility class from (HA Spring Boot Starter)

StringValuedEnum is a Enum base class, it enable JPA to persist `dataValue` instead of enum name into the Database. It also contain a `displayValue` that can be used by frontend.

### Create a custom Enum that implement StringValuedEnum

Create the following file `src/main/java/com/example/ecg/udt/Gender.java`.

```java
package com.example.ecg.udt;

import hk.org.ha.util.StringValuedEnum;
import hk.org.ha.util.StringValuedEnumConverter;
import hk.org.ha.util.StringValuedEnumReflect;
import jakarta.persistence.Converter;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum Gender implements StringValuedEnum {
    Male("M", "Male"),
    Female("F", "Female"),
    Unknown("U", "Unknown");

    private final String dataValue;
    private final String displayValue;

    public static Gender dataValueOf(String dataValue) {
        return StringValuedEnumReflect.getEnumFromValue(Gender.class, dataValue);
    }

    @Converter(autoApply = true)
    public static class EnumConverter extends StringValuedEnumConverter<Gender> {
        @Override
        public Class<Gender> getEnumClass() {
            return Gender.class;
        }
    }
}
```

### Expose the list of StringValuedEnum through Spring Boot RestController

Create the following file `src/main/java/com/example/ecg/controller/EnumController.java`.

```java
package com.example.ecg.controller;

import java.util.Arrays;
import java.util.List;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.ecg.udt.RecordStatus;
import hk.org.ha.util.EnumDto;
import hk.org.ha.util.EnumDtoBuilder;
import io.swagger.v3.oas.annotations.Operation;
import lombok.AllArgsConstructor;

@RestController
@RequestMapping(produces = MediaType.APPLICATION_JSON_VALUE)
@AllArgsConstructor
public class EnumController {

    @Operation(tags = "Enum")
    @GetMapping(path = "/enum")
    public List<EnumDto> getEnums() {
        return Arrays.asList(
                EnumDtoBuilder.build(RecordStatus.class));
    }
}

```

### Test the RESTful endpoint

Start server with below command:

```bash
$ mvnw spring-boot:run
```

Goto http://localhost:8080/enum You should see the following json:

```json
[
  {
    "name": "Gender",
    "items": [
      {
        "value": "Male",
        "dataValue": "M",
        "displayValue": "Male"
      },
      {
        "value": "Female",
        "dataValue": "F",
        "displayValue": "Female"
      },
      {
        "value": "Unknown",
        "dataValue": "U",
        "displayValue": "Unknown"
      }
    ]
  }
]
```

## Implement the Enum Code Generator on React Application

### Configuration Setup

Update the `package.json`

```json
{
  "scripts": {
    "enumgen": "node scripts/enumgen.js -- http://localhost:8080/enum src/generated/enum.ts"
  }
}
```

### Create the Enum Code Generator

Create the following file `scripts/enumgen.js`

```js
const fs = require("fs");

const log = console.log;

const args = process.argv.slice(2);
const inputUrl = args[1];
const outputFile = args[2];

function generateEnum({ name, items }) {
  return `
export const ${name}: ${name}Enum = {${items
    .map(
      (item) =>
        `
  ${item.value}: {
    value: "${item.value}",
    dataValue: "${item.dataValue}",
    displayValue: "${item.displayValue}",
  },`
    )
    .join("")}
};
`;
}

function generateType({ name, items }) {
  return `export type TypeOf${name} = ${items
    .map((item) => `"${item.value}"`)
    .join(" | ")};

export type ${name}Enum = {
  [key in TypeOf${name}]: {
    value: TypeOf${name};
    dataValue: string;
    displayValue: string;
  };
};
`;
}

function main() {
  if (!inputUrl || !outputFile) {
    console.log("missing required arguments.");
    return;
  }

  fetch(inputUrl)
    .then((response) => response.json())
    .then((body) => {
      // generate the typescript file
      const enums = body;
      const enumGenerated = enums
        .map((e) => `${generateType(e)}${generateEnum(e)}`)
        .join("\n");

      // write to filesystem
      fs.promises.writeFile(outputFile, enumGenerated);
    })
    .catch((error) => log(error));
}

main();
```

### Run the Code Generator

Run the enum generation command.

```bash
npm run enumgen
```

The following is the example of generated TypeScript file located at `src/generated/enum.ts`

```ts
export type TypeOfGender = "Male" | "Female" | "Unknown";

export type GenderEnum = {
  [key in TypeOfGender]: {
    value: TypeOfGender;
    dataValue: string;
    displayValue: string;
  };
};

export const Gender: GenderEnum = {
  Male: {
    value: "Male",
    dataValue: "M",
    displayValue: "Male",
  },
  Female: {
    value: "Female",
    dataValue: "F",
    displayValue: "Female",
  },
  Unknown: {
    value: "Unknown",
    dataValue: "U",
    displayValue: "Unknown",
  },
};
```

## React example of using the generated Enum

```tsx
import { useState } from "react";
import { UserStore } from "../../context/user/UserStore";
import { Gender, TypeOfGender } from "../../generated/enum";

export const AddUser = () => {
  const [name, setName] = useState("");
  const [gender, setGender] = useState<TypeOfGender>(Gender.Unknown.value);

  const { users, createUser } = UserStore.useContainer();

  function userExists(name: string) {
    return users.filter((user) => user.name === name).length > 0;
  }

  function addUser() {
    if (!name) {
      return;
    }
    if (userExists(name)) {
      alert("user already exists");
      return;
    }
    createUser({ name, gender });
    setName("");
  }

  return (
    <div>
      <input
        placeholder="Name"
        value={name}
        onChange={(e) => setName(e.target.value)}
        onKeyUp={(e) => e.key === "Enter" && addUser()}
      />
      <select
        value={gender}
        onChange={(e) => {
          setGender(e.target.value as TypeOfGender);
        }}
      >
        {Object.values(Gender).map((o) => (
          <option value={o.value} key={o.value}>
            {o.displayValue}
          </option>
        ))}
      </select>
      <button disabled={!name} onClick={addUser}>
        Add
      </button>
    </div>
  );
};
```
