#!/usr/bin/env bash
# Start script for the Spring Boot backend.
# - Detects Maven Wrapper (mvnw) usability or falls back to system Maven (mvn)
# - Maps PORT env var to Spring Boot server.port (default: 3001)
# - Avoids requiring executable bit by invoking via bash
# - Provides clear logs for the preview runner

set -euo pipefail

# Determine port: default to 3001 if not provided
PORT="${PORT:-3001}"

# JVM args for Spring Boot run
JVM_ARGS="-Dserver.port=${PORT}"

echo "[start.sh] Starting UP Tourism Project Monitoring Backend"
echo "[start.sh] Resolved PORT=${PORT}"
echo "[start.sh] Preferred start: ./mvnw spring-boot:run (-Dspring-boot.run.jvmArguments=\"${JVM_ARGS}\")"
echo "[start.sh] Fallback: mvn spring-boot:run"

run_with_mvnw() {
  echo "[start.sh] Using Maven Wrapper to start the app..."
  # Use bash to avoid relying on executable bit
  bash ./mvnw -DskipTests spring-boot:run -Dspring-boot.run.jvmArguments="${JVM_ARGS}"
}

run_with_mvn() {
  echo "[start.sh] Using system Maven (mvn) to start the app..."
  mvn -DskipTests spring-boot:run -Dspring-boot.run.jvmArguments="${JVM_ARGS}"
}

run_with_gradle() {
  echo "[start.sh] Using Gradle Wrapper to start the app (backup option)..."
  # Use bash to avoid relying on executable bit
  bash ./gradlew bootRun --args="--server.port=${PORT}"
}

# Determine if Maven Wrapper is usable (wrapper script + properties available)
MVNW_USABLE=false
if [ -f "./mvnw" ] && [ -f ".mvn/wrapper/maven-wrapper.properties" ]; then
  MVNW_USABLE=true
fi

if [ "${MVNW_USABLE}" = "true" ]; then
  echo "[start.sh] Maven Wrapper detected and appears usable (.mvn/wrapper/maven-wrapper.properties found)."
  set +e
  run_with_mvnw
  STATUS=$?
  set -e
  if [ ${STATUS} -ne 0 ]; then
    echo "[start.sh] WARNING: Maven Wrapper failed with status ${STATUS}. Falling back to system Maven (mvn) if available."
    if command -v mvn >/dev/null 2>&1; then
      run_with_mvn
      exit $?
    elif [ -f "./gradlew" ]; then
      echo "[start.sh] System Maven not found. Trying Gradle Wrapper as a last resort."
      run_with_gradle
      exit $?
    else
      echo "[start.sh] ERROR: Neither system Maven (mvn) nor Gradle Wrapper found. Please ensure Maven is available or include the Maven Wrapper."
      exit 1
    fi
  fi
elif command -v mvn >/dev/null 2>&1; then
  echo "[start.sh] Maven Wrapper not usable; falling back to system 'mvn'."
  run_with_mvn
elif [ -f "./gradlew" ]; then
  echo "[start.sh] Maven not available; using Gradle Wrapper as a last resort."
  run_with_gradle
else
  echo "[start.sh] ERROR: Neither Maven Wrapper (usable), system Maven (mvn), nor Gradle Wrapper present."
  echo "[start.sh] Please ensure Maven is available or include the Maven Wrapper (.mvn/wrapper/* and mvnw)."
  exit 1
fi
