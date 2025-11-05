#!/usr/bin/env bash
set -euo pipefail

# Idempotent scaffold for minimal Spring Boot Maven project
WORKSPACE="/home/kavia/workspace/code-generation/uttar-pradesh-tourism-project-monitoring-system-219422-219431/project_monitoring_backend"
SPRING_BOOT_VERSION="${SPRING_BOOT_VERSION:-3.1.4}"
PROJECT_DIR="$WORKSPACE"
TS=$(date +%s)

mkdir -p "$PROJECT_DIR" || (echo "ERROR: cannot create workspace $PROJECT_DIR" >&2; exit 201)
[ -f "$PROJECT_DIR/pom.xml" ] && cp -a "$PROJECT_DIR/pom.xml" "$PROJECT_DIR/pom.xml.bak.$TS" || true
[ -d "$PROJECT_DIR/src" ] && mv -f "$PROJECT_DIR/src" "$PROJECT_DIR/src.bak.$TS" || true

mkdir -p "$PROJECT_DIR/src/main/java/com/example/demo" "$PROJECT_DIR/src/main/resources" "$PROJECT_DIR/src/test/java/com/example/demo"

cat > "$PROJECT_DIR/pom.xml" <<POM
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>project-monitoring-backend</artifactId>
  <version>0.0.1-SNAPSHOT</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>${SPRING_BOOT_VERSION}</version>
    <relativePath/>
  </parent>
  <properties>
    <java.version>17</java.version>
  </properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.10.1</version>
        <configuration>
          <source>${java.version}</source>
          <target>${java.version}</target>
          <encoding>UTF-8</encoding>
        </configuration>
      </plugin>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <mainClass>com.example.demo.Application</mainClass>
          <layers>false</layers>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
POM

cat > "$PROJECT_DIR/src/main/java/com/example/demo/Application.java" <<'APP'
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
APP

cat > "$PROJECT_DIR/src/main/java/com/example/demo/HealthController.java" <<'CTR'
package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {
    @GetMapping("/health")
    public String health() {
        return "ok";
    }
}
CTR

cat > "$PROJECT_DIR/src/main/resources/application.properties" <<'PROP'
spring.datasource.url=jdbc:h2:mem:devdb;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.h2.console.enabled=false
logging.level.root=INFO
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
PROP

cat > "$PROJECT_DIR/src/test/java/com/example/demo/ApplicationTests.java" <<'TST'
package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class ApplicationTests {
    @Test
    void contextLoads() {}
}
TST

cat > "$PROJECT_DIR/.gitignore" <<GIT
/target
/*.log
GIT

cat > "$PROJECT_DIR/README.md" <<MD
Minimal Spring Boot scaffold for headless container development.

Usage: set SPRING_BOOT_VERSION env var to override default (3.1.4) before running this script.
MD

# final validation of reachable workspace
ls -la "$PROJECT_DIR" >/dev/null
