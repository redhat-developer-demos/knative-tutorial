#!/bin/bash

set -eu
set -o pipefail 

KSVC_NAME=${1:-'greeter'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

call_service(){
  local curr_ns
  curr_ns="$(current_namespace)"

  local host_header
  host_header="Host:$KSVC_NAME.$curr_ns.example.com"

  if [ $# -le 1 ]
  then
    curl -H "$host_header" $IP_ADDRESS
  else
    if [ -z "$2" ]
    then 
      curl -X POST -H "$host_header" $IP_ADDRESS
    else 
      curl -X POST -d "$2" -H "$host_header" $IP_ADDRESS
    fi
  fi
}

# Find the current namespace
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

call_service