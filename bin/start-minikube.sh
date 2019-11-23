#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-'knativetutorial'}
MEMORY=${MEMORY:-8192}
CPUS=${CPUS:-5}

minikube profile $PROFILE_NAME

minikube start --memory=$MEMORY --cpus=$CPUS \
  --kubernetes-version=v1.14.0 \
  --vm-driver=$VM_DRIVER \
  --disk-size=50g \
  --extra-config="apiserver.enable-admission-plugins=LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook" \
  --insecure-registry='10.0.0.0/24' 