#!/bin/bash

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

curl -H "Host:greeter.knativetutorial.example.com" $IP_ADDRESS
