# https://github.com/quarkusio/quarkus-images allows to set
# various maven build arguments such as MAVEN_MIRROR_URL, HTTP_PROXY_HOST etc.,
# it also allows building images with https://buildah.io

FROM quay.io/rhdevelopers/quarkus-java-builder as nativebuilder
COPY . /project
WORKDIR /project
# uncomment this to set the MAVEN_MIRROR_URL of your choice, to make faster builds
# ARG MAVEN_MIRROR_URL=<your-maven-mirror-url>
# e.g.
#ARG MAVEN_MIRROR_URL=http://192.168.64.1:8081/nexus/content/groups/public

RUN /usr/local/bin/entrypoint-run.sh mvn -DskipTests clean package -Pnative

FROM registry.fedoraproject.org/fedora-minimal
COPY --from=nativebuilder /project/target/*-runner /application
EXPOSE 8080
ENTRYPOINT ["/application"]
CMD ["-Dquarkus.http.host=0.0.0.0"]

