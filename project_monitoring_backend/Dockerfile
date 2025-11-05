# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
# Pre-fetch dependencies to leverage Docker layer caching
RUN mvn -q -B -e -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

# Run stage
FROM eclipse-temurin:17-jre
WORKDIR /app
ENV JAVA_OPTS="-Xms256m -Xmx512m"
COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 3001
# Default entrypoint to run the Spring Boot app
CMD ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
