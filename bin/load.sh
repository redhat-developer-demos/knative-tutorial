#!/bin/bash

KSVC_NAME=${1:-'prime-generator'}
HOST_HEADER="$KSVC_NAME.knativetutorial.example.com"

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

# Call the Knative prime-generator service with a load of 50 concurrent requests
# to find biggest prime with 10000
# allow each operation to sleep for 3 seconds
# and each requests add a load of 100m
hey -c 50 -z 10s \
  -host "$HOST_HEADER" \
  "http://$IP_ADDRESS/?sleep=3&upto=10000&memload=100"