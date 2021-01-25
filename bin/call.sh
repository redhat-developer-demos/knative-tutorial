#!/bin/bash

set -eu
set -o pipefail 

KSVC_NAME=${1:-'greeter'}

CURR_CTX=$(kubectl config current-context)

CURR_NS="$(kubectl config view -o=jsonpath="{.contexts[?(@.name==\"${CURR_CTX}\")].context.namespace}")" \
    || exit_err "error getting current namespace"

if [[ -z "${CURR_NS}" ]]; 
then
  CURR_NS='default'
else
  CURR_NS="${CURR_NS}"
fi

# HOST_HEADER="Host:$KSVC_NAME.$CURR_NS.example.com"
KSVC_HOST="$KSVC_NAME.$CURR_NS.$(minikube -p knativetutorial ip).nip.io"

if [ $# -le 1 ]
then
  http GET "$KSVC_HOST"
else
  echo "$2" | http --body POST "$KSVC_HOST"
fi

exit_err() {
   echo >&2 "${1}"
   exit 1
}

exit 0
