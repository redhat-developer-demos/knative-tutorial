#!/bin/bash

set -eu
set -o pipefail 

KSVC_NAME=${1:-'greeter'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc kourier-external --namespace kourier-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

CURR_CTX=$(kubectl config current-context)

CURR_NS="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${CURR_CTX}\")].context.namespace}")" \
    || exit_err "error getting current namespace"

if [[ -z "${CURR_NS}" ]]; 
then
  CURR_NS='default'
else
  CURR_NS="${CURR_NS}"
fi

HOST_HEADER="Host:$KSVC_NAME.$CURR_NS.example.com"

if [ $# -le 1 ]
then
  curl -H "$HOST_HEADER" $IP_ADDRESS
else
  if [ -z "$2" ]
  then 
    curl -X POST -H "$HOST_HEADER" $IP_ADDRESS
  else 
    curl -X POST -d "$2" -H "$HOST_HEADER" $IP_ADDRESS
  fi
fi

exit_err() {
   echo >&2 "${1}"
   exit 1
}

exit 0
