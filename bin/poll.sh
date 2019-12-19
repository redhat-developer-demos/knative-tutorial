#!/bin/bash

trap '{ echo "" ; exit 1; }' INT

KSVC_NAME=${1:-'greeter'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

while true
do
  curl -H "Host:$KSVC_NAME.knativetutorial.example.com" $IP_ADDRESS
  sleep .5
done

exit 0
