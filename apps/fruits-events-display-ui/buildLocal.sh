#!/bin/bash

set -eu

set -o pipefail

_CURR_DIR="$( cd "$(dirname "$0")" ; pwd -P )"

ARTIFACT_NAME=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.build.finalName -q -DforceStdout)
ARTIFACT_VERSION=$(mvn org.apache.maven.plugins:maven-help-plugin:3.1.1:evaluate -Dexpression=project.version -q -DforceStdout)

#mvn -DskipTests clean package -Pnative -Dnative-image.docker-build=true
mvn -DskipTests clean package


IMAGE_NAME="rhdevelopers/knative-tutorial-fruit-events-display:jvm-$ARTIFACT_VERSION"

IMAGE="$(minikube ip):5000/$IMAGE_NAME"

docker build -t $IMAGE  -f src/main/docker/Dockerfile.jvm $_CURR_DIR

docker push --tls-verify=false $IMAGE

yq w "$_CURR_DIR/kubernetes/app.yaml" -d1 'spec.template.spec.containers[0].image' "dev.local/$IMAGE_NAME" |\
 yq w - -d1 'spec.template.spec.containers[0].resources.limits.memory' "128Mi" |\
  kubectl apply -f -