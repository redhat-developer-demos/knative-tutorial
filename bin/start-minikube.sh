#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-knativetutorial}
VM_DRIVER=${VM_DRIVER:-virtualbox}
MEMORY=${MEMORY:-8192}
CPUS=${CPUS:-6}

EXTRA_CONFIG="apiserver.enable-admission-plugins=\
LimitRanger,\
NamespaceExists,\
NamespaceLifecycle,\
ResourceQuota,\
ServiceAccount,\
DefaultStorageClass,\
MutatingAdmissionWebhook"

minikube start --memory=$MEMORY --cpus=$CPUS \
  --kubernetes-version=v1.14.0 \
  --vm-driver="$VM_DRIVER" \
  --disk-size=50g \
  --extra-config="$EXTRA_CONFIG" \
  --insecure-registry='10.0.0.0/24' 