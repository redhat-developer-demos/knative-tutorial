#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-knativetutorial}
MEMORY=${MEMORY:-8192}
CPUS=${CPUS:-6}

minikube start -p $PROFILE_NAME \
  --memory=$MEMORY \
  --cpus=$CPUS \
  --kubernetes-version=v1.19.0 \
  --disk-size=50g \
  --insecure-registry='10.0.0.0/24' 
