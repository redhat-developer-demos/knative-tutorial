#!/bin/bash

KSVC_NAME=${1:-'greeter'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

if [ $# -le 1 ]
then
  curl -H "Host:$KSVC_NAME.knativetutorial.example.com" $IP_ADDRESS
else
  if [ -z "$2" ]
  then 
    curl -X POST -H "Host:$KSVC_NAME.knativetutorial.example.com" $IP_ADDRESS
  else 
    curl -X POST -d "$2" -H "Host:$KSVC_NAME.knativetutorial.example.com" $IP_ADDRESS
  fi
fi
