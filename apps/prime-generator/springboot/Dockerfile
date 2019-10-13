FROM quay.io/rhdevelopers/quarkus-java-builder:graal-1.0.0-rc15 as builder
COPY . /project

# uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
# ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
# e.g.
# ARG MAVEN_MIRROR_URL=http://192.168.0.105:8081/nexus/content/groups/public

RUN /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package

FROM fabric8/java-jboss-openjdk8-jdk:1.5.4
USER jboss
ENV JAVA_APP_DIR=/deployments
EXPOSE 8080
COPY --from=builder /project/target/prime-generator.jar /deployments/
ENTRYPOINT [ "/deployments/run-java.sh" ]