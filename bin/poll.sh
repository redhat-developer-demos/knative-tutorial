#!/bin/bash

trap '{ echo "" ; exit 1; }' INT

KSVC_NAME=${1:-'greeter'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

call_service(){
  local curr_ns
  curr_ns="$(current_namespace)"

  local host_header
  host_header="Host:$KSVC_NAME.$curr_ns.example.com"

  while true
  do
    curl -H "$host_header" $IP_ADDRESS
    sleep .5
  done
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

exit 0
