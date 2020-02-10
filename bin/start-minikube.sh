#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-knativecookbook}
MEMORY=${MEMORY:-8192}
CPUS=${CPUS:-4}

EXTRA_CONFIG="apiserver.enable-admission-plugins=\
LimitRanger,\
NamespaceExists,\
NamespaceLifecycle,\
ResourceQuota,\
ServiceAccount,\
DefaultStorageClass,\
MutatingAdmissionWebhook"

minikube profile $PROFILE_NAME
minikube start --memory=$MEMORY --cpus=$CPUS \
  --kubernetes-version=v1.15.0 \
  --disk-size=50g \
  --extra-config="$EXTRA_CONFIG" \
  --insecure-registry='10.0.0.0/24' 