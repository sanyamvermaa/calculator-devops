# ============================================================
# Stage 1 — BUILD: compile the JAR using Maven + JDK 21
# ============================================================
FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /workspace

# Step A: copy ONLY the pom.xml first so Docker caches dependency
# resolution. If pom.xml hasn't changed, the next 'docker build' skips
# re-downloading dependencies.
COPY pom.xml .
RUN mvn -B -ntp dependency:go-offline

# Step B: now copy sources and build. Changes to Java code don't invalidate
# the heavy dependency layer above.
COPY src ./src
RUN mvn -B -ntp clean package -DskipTests

# ============================================================
# Stage 2 — RUNTIME: slim JRE, just enough to run the JAR
# ============================================================
FROM eclipse-temurin:21-jre-alpine

# wget is used by the Compose health check; curl is handy for debugging
RUN apk add --no-cache wget

# Create a non-root user and group
RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

# Copy ONLY the built JAR out of the build stage
COPY --from=build --chown=app:app /workspace/target/calculator-devops-*.jar /app/app.jar

# Document the port — doesn't actually publish it, just metadata.
EXPOSE 8080

# Drop privileges — never run containers as root in production
USER app

# JVM entry point. The exec form (JSON array) means PID 1 is Java,
# which gets signals properly (Ctrl+C, 'docker stop', etc).
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
