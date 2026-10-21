# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn -B clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:21-jre

WORKDIR /app

# Install curl for the application healthcheck
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and group
RUN groupadd --system spring \
    && useradd --system \
       --gid spring \
       --home-dir /app \
       --shell /usr/sbin/nologin \
       spring

# Copy the application JAR with the correct ownership
COPY --from=builder --chown=spring:spring \
    /app/target/demo-0.0.1-SNAPSHOT.jar app.jar

# Run the application as a non-root user
USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
