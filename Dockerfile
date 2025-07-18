# Multi-stage for tiny final image
FROM maven:3.9.8-eclipse-temurin-21-alpine AS build
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package

FROM eclipse-temurin:21-jre-alpine
COPY --from=build /target/kuberdemo-0.0.1-SNAPSHOT.jar /app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
