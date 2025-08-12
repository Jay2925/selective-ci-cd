FROM maven:3.9-eclipse-temurin-17 as build
WORKDIR /src
COPY pom.xml .
RUN mvn -q -e -B -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -e -B -DskipTests=false clean package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/target/monolith-0.0.1.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
