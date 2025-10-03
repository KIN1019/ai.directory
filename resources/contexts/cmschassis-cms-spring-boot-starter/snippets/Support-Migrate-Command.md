# Migrate Command

A command-line helper command for your convenience. you should include all of them in your project root folder.

## For Mac or Unix

Create a file name `migrate`

```sh
#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Usage: migrate [command] [command options]"
  exit
fi

if [ -z "$JAVA_OPTS" ] ; then
  JAVA_OPTS="-Dspring.profiles.active=deploy"
fi
java -Duser.timezone=Asia/Hong_Kong -Dmybatis.migrations.enabled=true $JAVA_OPTS -jar target/*.jar migrations "$@"
```

> Notes that if you are using multi modules maven project, please change from `target/*.jar` to `app/target/*.jar`.

Create a hidden file named `.gitattributes` to elimitate the windows end of line charater `^M` when upload to Git.

```
*.sh text eol=lf
migrate text eol=lf
```

## For Windows

Create a file named `migrate.cmd`

```bat
@echo off

if "%*"=="" goto USAGE

if "%JAVA_OPTS%" == "" (
  set JAVA_OPTS=-Dspring.profiles.active=deploy
)
for %%i in (target\*.jar) do java -Duser.timezone=Asia/Hong_Kong -Dmybatis.migrations.enabled=true %JAVA_OPTS% -jar "%%i" migrations %*

goto EOF

:USAGE
echo "Usage: migrate [command] [command options]"
exit 1
:EOF
```

> Notes that if you are using multi-modules maven project, please change from `target\*.jar` to `app\target\*.jar`.
