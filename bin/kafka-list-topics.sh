#!/bin/bash
set -e 

trap '{ echo "" ; exit 1; }' INT

KAFKA_CLUSTER_NS=${1:-'kafka'}
KAFKA_CLUSTER_NAME=${2:-'my-cluster'}

pod_number=$(shuf -i 0-1 -n 1)
kubectl exec -it "$KAFKA_CLUSTER_NAME-kafka-$pod_number" \
 -n $KAFKA_CLUSTER_NS \
 -- ./bin/kafka-topics.sh \
 --list \
 --zookeeper localhost:2181
