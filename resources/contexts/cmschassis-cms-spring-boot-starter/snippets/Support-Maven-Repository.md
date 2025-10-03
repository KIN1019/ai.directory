# Maven Repository

## Office setup

Create or update your `~/.m2/settings.xml` as follow.

```xml
<settings
    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 http://maven.apache.org/xsd/settings-1.2.0.xsd"
    xmlns="http://maven.apache.org/SETTINGS/1.2.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <servers>
        <server>
            <id>central</id>
            <username>${env.ARTIFACTORY_USER}</username>
            <password>${env.ARTIFACTORY_TOKEN}</password>
        </server>
        <server>
            <id>snapshots</id>
            <username>${env.ARTIFACTORY_USER}</username>
            <password>${env.ARTIFACTORY_TOKEN}</password>
        </server>
    </servers>
    <profiles>
        <profile>
            <repositories>
                <repository>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                    <id>central</id>
                    <name>maven-dev-cmschassis</name>
                    <url>https://artifactrepo.server.ha.org.hk:55743/artifactory/maven-dev-cmschassis</url>
                </repository>
                <repository>
                    <snapshots />
                    <id>snapshots</id>
                    <name>maven-dev-cmschassis</name>
                    <url>https://artifactrepo.server.ha.org.hk:55743/artifactory/maven-dev-cmschassis</url>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                    <id>central</id>
                    <name>maven-dev-cmschassis</name>
                    <url>https://artifactrepo.server.ha.org.hk:55743/artifactory/maven-dev-cmschassis</url>
                </pluginRepository>
                <pluginRepository>
                    <snapshots />
                    <id>snapshots</id>
                    <name>maven-dev-cmschassis</name>
                    <url>https://artifactrepo.server.ha.org.hk:55743/artifactory/maven-dev-cmschassis</url>
                </pluginRepository>
            </pluginRepositories>
            <id>artifactory</id>
        </profile>
    </profiles>
    <activeProfiles>
        <activeProfile>artifactory</activeProfile>
    </activeProfiles>
</settings>
```

> Notes that you should replace `maven-dev-cmschassis` to your team's repository.
>
> Please refer to [this page](https://hagithub.home/CDRA/workflow-template/blob/main/doc/artifactory-setup.md#access-chassis-dependencies-and-libraries) to request CDC3 to setup `chassis` linkage to your repo.

## Remote setup

Create or update your `~/.m2/settings.xml` as follow.

```xml
<settings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://maven.apache.org/SETTINGS/1.0.0"
    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <mirrors>
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <url>https://nexus3.haitcl.org/repository/maven-public/</url>
        </mirror>
    </mirrors>
    <profiles>
        <profile>
            <id>nexus</id>
            <repositories>
                <repository>
                    <id>central</id>
                    <url>http://central</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <id>central</id>
                    <url>http://central</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                    </snapshots>
                </pluginRepository>
            </pluginRepositories>
        </profile>
    </profiles>

    <activeProfiles>
        <activeProfile>nexus</activeProfile>
    </activeProfiles>
</settings>
```
