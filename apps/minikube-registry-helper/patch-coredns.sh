#!/bin/bash
# A script that wil be used to patch the core dns aliases
# e.g say i want dev.local to be mapped to default registry registry.kube-system.cluster.svc.local
#
set -eu

set -o pipefail 

# clean up old files if they exist
rm -f /tmp/coredns-alias-patch.yaml
rm -f /tmp/coredns-alias-prepatch.yaml

REGISTRY_ALIASES=$(kubectl get cm registry-aliases -n kube-system -oyaml | yq r - data.registryAliases)
REGISTRY_SVC=$(kubectl get cm registry-aliases -n kube-system -oyaml | yq r - data.registrySvc) 
ALIASES_ENTRIES=""
NL_DELIMITER='~'
SPACES='  '
RW_RULE='rewrite name '

OLDIFS=$IFS

IFS=

# store the previous value for further processing 
kubectl get cm coredns -n kube-system -oyaml | yq r - data.Corefile  | tee /tmp/coredns-alias-prepatch.yaml > /dev/null

nStart=$(grep -n -m 1 "$REGISTRY_SVC"  /tmp/coredns-alias-prepatch.yaml | head -n1 | cut -d: -f1 || true )
nEnd=$(grep -n "$REGISTRY_SVC" /tmp/coredns-alias-prepatch.yaml | tail -n1 | cut -d: -f1 || true )

#echo "Pattern Start line: $nStart Ending line : $nEnd"

# remove old entries 
if [ -n "$nStart" ] && [ -n "$nEnd" ]; 
then
   sed -i "$nStart,${nEnd}d" /tmp/coredns-alias-prepatch.yaml > /dev/null
fi

IFS=$OLDIFS

for H in $REGISTRY_ALIASES; 
do    
    [ -n  "$ALIASES_ENTRIES" ] && ALIASES_ENTRIES="$ALIASES_ENTRIES$NL_DELIMITER"
    ALIASES_ENTRIES="$ALIASES_ENTRIES$RW_RULE$H$SPACES$REGISTRY_SVC"
done

ALIASES_ENTRIES="$ALIASES_ENTRIES$NL_DELIMITER"

IFS=

if [ -n "$ALIASES_ENTRIES" ];
then
   # Add the rename rewrites after string health
   sed "/health/a\\
     $ALIASES_ENTRIES" < /tmp/coredns-alias-prepatch.yaml| tr '~' '\n' | tee /tmp/coredns-alias-patch.yaml > /dev/null
   yq w -i /tmp/coredns-alias-patch.yaml data.Corefile "$(cat /tmp/coredns-alias-patch.yaml)"
   # echo "Patch to be applied"
   #cat  /tmp/coredns-alias-patch.yaml
   kubectl patch cm coredns -n kube-system --patch "$(cat /tmp/coredns-alias-patch.yaml)"
else
  echo "No Aliass entries found, skipping patch"
fi 
