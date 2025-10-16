# ---- Stage 1: Build the application ----
FROM maven:3.9.8-eclipse-temurin-21 AS builder
WORKDIR /app

# Copy the pom.xml and download dependencies (cached separately)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests

# ---- Stage 2: Create the runtime image ----
FROM openjdk:21-jdk
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]