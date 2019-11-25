#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-'knativetutorial'}
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

<<<<<<< HEAD
minikube profile "$PROFILE_NAME"

minikube start --memory="$MEMORY" --cpus="$CPUS" \
=======
minikube start --memory=$MEMORY --cpus=$CPUS \
>>>>>>> 99d0ef4783184bd533d0ab28d09a303989041abc
  --kubernetes-version=v1.14.0 \
  --vm-driver="$VM_DRIVER" \
  --disk-size=50g \
  --extra-config="$EXTRA_CONFIG" \
  --insecure-registry='10.0.0.0/24' 