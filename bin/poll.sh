#!/bin/bash
set -eu
set -o pipefail

trap '{ echo "" ; exit 1; }' INT

KSVC_NAME=${1:-'greeter'}


CURR_CTX=$(kubectl config current-context)

CURR_NS="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${CURR_CTX}\")].context.namespace}")" \
    || exit_err "error getting current namespace"

if [[ -z "${CURR_NS}" ]]; 
then
  CURR_NS="default"
else
  CURR_NS="${CURR_NS}"
fi

HOST_HEADER="Host:$KSVC_NAME.$CURR_NS.example.com"

while true
do
  curl -H "$HOST_HEADER" $IP_ADDRESS
  sleep .5
done

exit_err() {
   echo >&2 "${1}"
   exit 1
}

exit 0
