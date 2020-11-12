#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-knativetutorial}
MEMORY=${MEMORY:-8192}
CPUS=${CPUS:-6}

unamestr=$(uname)

if [ "$unamestr" == "Darwin" ];
then
  minikube start -p "$PROFILE_NAME" \
  --memory="$MEMORY" \
  --driver=hyperkit \
  --cpus="$CPUS" \
  --kubernetes-version=v1.19.0 \
  --disk-size=50g \
  --insecure-registry='10.0.0.0/24' 
else
  minikube start -p "$PROFILE_NAME" \
  --memory="$MEMORY" \
  --cpus="$CPUS" \
  --kubernetes-version=v1.19.0 \
  --disk-size=50g \
  --insecure-registry='10.0.0.0/24' 
fi
