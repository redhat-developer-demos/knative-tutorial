FROM gcr.io/cloud-builders/mvn as builder
COPY . /project
WORKDIR /project
RUN mvn -Duser.home=/builder/home -B -DskipTests install

FROM fabric8/java-jboss-openjdk8-jdk:1.5.4
USER jboss
ENV JAVA_APP_DIR=/deployments
EXPOSE 8080
COPY --from=builder /project/target/greeter.jar /deployments/
ENTRYPOINT [ "/deployments/run-java.sh" ]