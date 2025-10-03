# HA Spring Boot Starter Migrate

The HA Spring Boot Starter Migrate includes the submodule for database schema initialization and migration.

## Database Schema Migration

MyBatis Migrations for Spring Boot is a database migration tool specifically designed to help manage database schema changes and versioning in an organized and controlled manner.

This autoconfiguration feature in Spring Boot eliminates the need for manual setup and configuration of MyBatis Migrations. It automatically configures the necessary beans and dependencies, allowing developers to focus on defining and executing database migrations without worrying about the infrastructure setup.

### Dependencies and setup

To use Spring Boot autoconfiguration for MyBatis Migrations, you need to include the appropriate dependencies in your project. Typically, you would include the following Maven coordinates in your `pom.xml`:

```xml
<dependency>
    <groupId>hk.org.ha</groupId>
    <artifactId>ha-spring-boot-starter-migrate</artifactId>
</dependency>
```

### Prepare the migration scripts

Create the following file `src/main/resources/dbmigrate/scripts/<yyyymmddHHmmss>_create_changelog.sql`.

> e.g. 20230812020020_create_changelog.sql

```sql
-- // Create Changelog

-- Default DDL for changelog table that will keep
-- a record of the migrations that have been run.

-- You can modify this to suit your database before
-- running your first migration.

-- Be sure that ID and DESCRIPTION fields exist in
-- BigInteger and String compatible fields respectively.

create table ${changelog} (
  id numeric(20,0) not null,
  applied_at varchar(25) not null,
  description varchar(255) not null,
  primary key(id)
);

-- //@UNDO
drop table ${changelog};
```

Create the following file `src/main/resources/scripts/<yyyymmddHHmmss>_first_migration.sql`.

> e.g. 20230812020021_first_migration.sql

```sql
-- // First migration.
-- Migration SQL that makes the change goes here.
create table usr (
  id varchar(36) not null,
  name varchar(255) not null,
  nick_name varchar(255) null,
  primary key(id)
);

-- //@UNDO
-- SQL to undo the change goes here.
drop table usr;
```

### Test the migration scripts

Here is the procedure for testing migration scripts on your local machine.

#### Build the package jar

In order to use the migration scripts you need to first package the project jar as follow:

```sh
mvnw clean package -DskipTests
```

#### Execution of migrate command

Please first copy the [Migrate Command](Support-Migrate-Command) script into your project root folder.

1. Start postgres on local container engine.

```sh
podman run -it --rm --name some-postgres -p 5432:5432 -e POSTGRES_HOST_AUTH_METHOD=trust postgres
```

2. Update your `DATABASE_URL` environment variable.

```sh
set DATABASE_URL=jdbc:postgresql://localhost:5432/postgres?user=postgres
```

3. Run the below command and look at migration status before executing the scripts.

```sh
> migrate status

ID             Applied At          Description
================================================================================
20230812020020    ...pending...    create changelog
20230812020021    ...pending...    first migration
```

4. Execution of the migrate script.

```sh
> migrate up
```

5. Run the below command again to check the applied time.

```sh
> migrate status

ID             Applied At          Description
================================================================================
20230812020020 2023-08-12 11:43:46 create changelog
20230812020021 2023-08-12 11:43:46 first migration
```

> You can rollback of the last migration script by execute `migrate down`

### Automatic database migration during deployment

The corporate Github pipeline will automatically execute the `migrate up` command on each target environment if you enable the following settings in the `values-[ENV].yaml` file.

```yaml
dbmigrate:
  enable: true
  autoconfigure:
    enable: true
    migrateCommand: ./migrate up
  secret:
    name: xxxxxxx-svc-main-secret
```
