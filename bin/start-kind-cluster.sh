#!/bin/bash

set -eu
set -o errexit

export CLUSTER_NAME=${CLUSTER_NAME:-knativetutorial}
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# create registry container unless it already exists
export CONTAINER_REGISTRY_NAME='kind-registry'
export CONTAINER_REGISTRY_PORT='5000'

running="$(docker inspect -f '{{.State.Running}}' "${CONTAINER_REGISTRY_NAME}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${CONTAINER_REGISTRY_PORT}:5000" --name "${CONTAINER_REGISTRY_NAME}" \
    registry:2
fi

# create a cluster with the local registry enabled in containerd
envsubst < ${CURRENT_DIR}/kind-cluster-config.yaml | kind create cluster \
  --name="${CLUSTER_NAME}" --config=-

# connect the registry to the cluster network only for new 
if [ "${running}" != 'true' ]; then
  docker network connect "kind" "${CONTAINER_REGISTRY_NAME}"
fi

## Label nodes for using registry 
# tell https://tilt.dev to use the registry
# https://docs.tilt.dev/choosing_clusters.html#discovering-the-registry
for node in $(kind get nodes --name="$CLUSTER_NAME"); do
  kubectl annotate node "${node}" \
    "tilt.dev/registry=localhost:${CONTAINER_REGISTRY_PORT}" \
    "tilt.dev/registry-from-cluster=${CONTAINER_REGISTRY_NAME}:${CONTAINER_REGISTRY_PORT}";
done

## Label worker nodes
kubectl  get nodes --no-headers -l '!node-role.kubernetes.io/master' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I{} kubectl label node {} node-role.kubernetes.io/worker=''

## Setup helm

helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update


###################################
# Nginx Ingress 
###################################

## Label Worker nodes as nginx ingress
kubectl  get nodes --no-headers -l '!node-role.kubernetes.io/master' -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | xargs -I{} kubectl label node {} nginx=ingresshost

kubectl create ns ingress-nginx

helm install ingress-nginx stable/nginx-ingress --namespace ingress-nginx \
  --set controller.nodeSelector.nginx="ingresshost" \
  --set rbac.create=true --set controller.image.pullPolicy="Always" \
  --set controller.extraArgs.enable-ssl-passthrough="" \
  --set controller.stats.enabled=true --set controller.service.type="ClusterIP" \
  --set controller.kind="DaemonSet" --set controller.daemonset.useHostPort=true

kubectl rollout status ds ingress-nginx-nginx-ingress-controller -n ingress-nginx
kubectl rollout status deploy ingress-nginx-nginx-ingress-default-backend -n ingress-nginx