#!/usr/bin/env bash
# Start script for the Spring Boot backend.
# - Detects Maven Wrapper (mvnw) or Gradle Wrapper (gradlew)
# - Maps PORT env var to Spring Boot server.port (default: 3001)
# - Avoids requiring executable bit by invoking via bash

set -euo pipefail

# Determine port: default to 3001 if not provided
PORT="${PORT:-3001}"

# JVM args for Spring Boot run
JVM_ARGS="-Dserver.port=${PORT}"

echo "Starting UP Tourism Project Monitoring Backend on port ${PORT}..."

run_with_maven() {
  echo "Using Maven Wrapper to start the app..."
  # Use bash to avoid relying on executable bit
  bash ./mvnw -DskipTests spring-boot:run -Dspring-boot.run.jvmArguments="${JVM_ARGS}"
}

run_with_gradle() {
  echo "Using Gradle Wrapper to start the app..."
  # Use bash to avoid relying on executable bit
  bash ./gradlew bootRun --args="--server.port=${PORT}"
}

if [ -f "./mvnw" ]; then
  run_with_maven
elif [ -f "./gradlew" ]; then
  run_with_gradle
elif command -v mvn >/dev/null 2>&1; then
  echo "Maven wrapper not found; falling back to system 'mvn'."
  mvn -DskipTests spring-boot:run -Dspring-boot.run.jvmArguments="${JVM_ARGS}"
else
  echo "Error: Neither Maven Wrapper (mvnw) nor system Maven (mvn) found, and no Gradle wrapper present."
  echo "Please ensure Maven is available or include the Maven Wrapper."
  exit 1
fi
