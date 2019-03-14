#!/bin/bash
# A script that wil be used to patch the core dns aliases
# e.g say i want dev.local to be mapped to default registry registry.kube-system.cluster.svc.local
#
set -eu

# clean up old files if they exist
rm -f /tmp/coredns-alias-patch.yaml
rm -f /tmp/coredns-alias-prepatch.yaml

REGISTRY_ALIASES=$(kubectl get cm registry-aliases -n kube-system -oyaml | yq r - data.registryAliases)
REGISTRY_SVC=$(kubectl get cm registry-aliases -n kube-system -oyaml | yq r - data.registrySvc) 
ALIASES_ENTRIES=""
NL='\n'
SPACES='  '
RW_RULE='rewrite name '

OLDIFS=$IFS

IFS=

# store the previous value for further processing 
kubectl get cm coredns -n kube-system -oyaml | yq r - data.Corefile  | tee /tmp/coredns-alias-prepatch.yaml 2>&1 > /dev/null
CURR_VALUE=$(cat /tmp/coredns-alias-prepatch.yaml)

nStart=$(grep -n -m 1 "$REGISTRY_SVC"  /tmp/coredns-alias-prepatch.yaml | head -n1 | cut -d: -f1 )
nEnd=$(grep -n "$REGISTRY_SVC" /tmp/coredns-alias-prepatch.yaml | tail -n1 | cut -d: -f1 )

#echo "Pattern Start line: $nStart Ending line : $nEnd"

# remove old entries 
if [ ! -z $nStart ] && [ ! -z $nEnd ]; 
then
   sed -i "$nStart,${nEnd}d" /tmp/coredns-alias-prepatch.yaml 2>&1 > /dev/null
fi

IFS=$OLDIFS

for H in $REGISTRY_ALIASES; 
do    
    [ ! -z "$ALIASES_ENTRIES" ] && ALIASES_ENTRIES="$ALIASES_ENTRIES$NL"
    ALIASES_ENTRIES="$ALIASES_ENTRIES$RW_RULE$H$SPACES$REGISTRY_SVC"
done

IFS=

# Add the rename rewrites after string health
cat /tmp/coredns-alias-prepatch.yaml | sed "/health/a\ $ALIASES_ENTRIES" | tee /tmp/coredns-alias-patch.yaml 2>&1 > /dev/null

yq w -i /tmp/coredns-alias-patch.yaml data.Corefile $(cat  /tmp/coredns-alias-patch.yaml)

# echo "Patch to be applied"
#cat  /tmp/coredns-alias-patch.yaml

kubectl patch cm coredns -n kube-system --patch $(cat /tmp/coredns-alias-patch.yaml)
