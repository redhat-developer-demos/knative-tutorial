#!/bin/bash

set -eu
set -o pipefail

CPUS=${CPUS:-6}
KNATIVE_VERSION=${KNATIVE_VERSION:-v0.17.0}
KNATIVE_SERVING_VERSION=${KNATIVE_SERVING_VERSION:-v0.17.0}
MEMORY=${MEMORY:-8192}
PROFILE_NAME=${PROFILE_NAME:-boson-quickstarts}

minikube start -p "$PROFILE_NAME" \
  --memory="$MEMORY" \
  --cpus="$CPUS" \
  --disk-size=50g \
  --insecure-registry='10.0.0.0/24' 

minikube profile "$PROFILE_NAME"

minikube addons enable registry
minikube addons enable registry-aliases

###################################
# Ingress 
###################################

kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

kubectl rollout status ds envoy -n projectcontour
kubectl rollout status deploy contour -n projectcontour

######################################
## Knative CRD
######################################

kubectl apply \
  --filename "https://github.com/knative/serving/releases/download/$KNATIVE_SERVING_VERSION/serving-crds.yaml"

######################################
## Knative Serving
######################################

kubectl apply \
  --filename "https://github.com/knative/serving/releases/download/$KNATIVE_SERVING_VERSION/serving-crds.yaml" 

kubectl apply \
  --filename \
  "https://github.com/knative/serving/releases/download/$KNATIVE_SERVING_VERSION/serving-core.yaml"

kubectl rollout status deploy controller -n knative-serving 
kubectl rollout status deploy activator -n knative-serving 
kubectl rollout status deploy autoscaler -n knative-serving 
kubectl rollout status deploy webhook -n knative-serving 

kubectl apply \
  --filename \
   "https://github.com/knative/net-kourier/releases/download/$KNATIVE_VERSION/kourier.yaml"
  
kubectl rollout status deploy 3scale-kourier-control -n knative-serving
kubectl rollout status deploy 3scale-kourier-gateway -n kourier-system

kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

cat <<EOF | kubectl apply -n kourier-system -f -
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: kourier-ingress
  namespace: kourier-system
spec:
  backend:
    serviceName: kourier
    servicePort: 80
EOF

# skip registriesSkippingTagResolving for few local and development registry prefixes
kubectl patch configmap/config-deployment \
    -n knative-serving \
    --type merge \
    -p '{"data":{"registriesSkippingTagResolving": "ko.local,dev.local,example.com,example.org,test.com,test.org,localhost:5000"}}'

# set nip.io resolution 
ksvc_domain="\"data\":{\""$(minikube ip)".nip.io\": \"\"}"
kubectl patch configmap/config-domain \
    -n knative-serving \
    --type merge \
    -p "{$ksvc_domain}"

######################################
## Quickstart demo namespace
######################################

kubectl create namespace boson-quickstarts
kubectl config set-context --current --namespace boson-quickstarts