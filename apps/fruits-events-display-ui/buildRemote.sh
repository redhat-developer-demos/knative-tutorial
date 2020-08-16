#!/bin/bash

set -eu

set -o pipefail

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

ARTIFACT_NAME=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.build.finalName -q -DforceStdout)
ARTIFACT_VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.version -q -DforceStdout)

mvn -DskipTests clean package -Pnative -Dnative-image.docker-build=true
#mvn -DskipTests clean package -Dnative-image.docker-build=true

IMAGE=${1:-"quay.io/rhdevelopers/knative-tutorial-fruit-events-display:$ARTIFACT_VERSION"}

docker build -t $IMAGE  -f src/main/docker/Dockerfile.native $_CURR_DIR

docker push $IMAGE