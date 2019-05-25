#!/bin/bash 

./mvnw clean install

_NAME=$(xml sel -N ns="http://maven.apache.org/POM/4.0.0" -t -v "//ns:project/ns:artifactId/text()" ./pom.xml)
_VERSION=$(xml sel -N ns="http://maven.apache.org/POM/4.0.0" -t -v "//ns:project/ns:version/text()" ./pom.xml)

docker build -t ${DOCKER_USER:-dev.local/rhdevelopers}/${_NAME}:${_VERSION} -f Dockerfile.all .
