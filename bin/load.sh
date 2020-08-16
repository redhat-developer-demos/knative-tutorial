#!/bin/bash

KSVC_NAME=${1:-'prime-generator'}

IP_ADDRESS="$(minikube ip):$(kubectl get svc kourier-external --namespace kourier-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')"

CURR_CTX=$(kubectl config current-context)

CURR_NS="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${CURR_CTX}\")].context.namespace}")" \
    || exit_err "error getting current namespace"

if [[ -z "${CURR_NS}" ]]; 
then
  CURR_NS="default"
else
  CURR_NS="${CURR_NS}"
fi

HOST_HEADER="$KSVC_NAME.$CURR_NS.example.com"

# Call the Knative prime-generator service with a load of 50 concurrent requests
# to find biggest prime with 10000
# allow each operation to sleep for 3 seconds
# and each requests add a load of 100m
hey -c 50 -z 10s \
  -host "$HOST_HEADER" \
  "http://$IP_ADDRESS/?sleep=3&upto=10000&memload=100"

# Find the c#urrent namespace
exit_err() {
   echo >&2 "${1}"
   exit 1
}

exit 0