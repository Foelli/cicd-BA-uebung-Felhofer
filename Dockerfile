# Build stage (Maven + JDK)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn -B -DskipTests package && ls -la target

RUN JAR_FILE="$(ls target/*-SNAPSHOT.jar 2>/dev/null || ls target/*.jar | head -n1)" \
    && echo "Using JAR: ${JAR_FILE}" \
    && cp "${JAR_FILE}" /app/app.jar

# Runtime stage
#FROM eclipse-temurin:17-jre-jammy AS runtime
#WORKDIR /app
#COPY --from=build /app/app.jar ./app.jar
#EXPOSE 8080

#ENTRYPOINT ["java","-cp","/app/app.jar","com.example.cicd.App"]

# Vulnerable runtime stage
FROM openjdk:11-jre-slim AS runtime
WORKDIR /app

# Add extra packages that introduce more CVEs
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /app/app.jar ./app.jar
EXPOSE 8080

ENTRYPOINT ["java","-cp","/app/app.jar","com.example.cicd.App"]
