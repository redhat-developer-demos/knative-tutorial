#!/bin/bash
set -e 

trap '{ echo "" ; exit 1; }' INT

KAFKA_TOPIC=${1:-'my-topic'}
KAFKA_CLUSTER_NS=${2:-'kafka'}
KAFKA_CLUSTER_NAME=${3:-'my-cluster'}


kubectl -n $KAFKA_CLUSTER_NS run kafka-producer -ti \
 --image=quay.io/strimzi/kafka:0.26.1-kafka-3.0.0 \
 --rm=true --restart=Never \
 -- bin/kafka-console-producer.sh\
 --broker-list $KAFKA_CLUSTER_NAME-$KAFKA_CLUSTER_NS-bootstrap:9092 \
 --topic $KAFKA_TOPIC
