#!/bin/bash 

set -e

kubectl create namespace observability
kubectl create \
  -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing.io_jaegers_crd.yaml \
  -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml \
  -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml \
  -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml \
  -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml
