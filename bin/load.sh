#!/bin/bash

KSVC_NAME=${1:-'prime-generator'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

load_service(){

local curr_ns
curr_ns="$(current_namespace)"

HOST_HEADER="$KSVC_NAME.$curr_ns.example.com"

# Call the Knative prime-generator service with a load of 50 concurrent requests
# to find biggest prime with 10000
# allow each operation to sleep for 3 seconds
# and each requests add a load of 100m
hey -c 50 -z 10s \
  -host "$HOST_HEADER" \
  "http://$IP_ADDRESS/?sleep=3&upto=10000&memload=100"
}

# Find the c#urrent namespace
current_namespace(){
  local curr_ctx
  local curr_ns

  curr_ctx=$(kubectl config current-context)

  curr_ns="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${curr_ctx}\")].context.namespace}")" \
     || exit_err "error getting current namespace"

  if [[ -z "${curr_ns}" ]]; 
  then
    echo "default"
  else
    echo "${curr_ns}"
  fi
}

exit_err() {
   echo >&2 "${1}"
   exit 1
}

load_service

exit 0