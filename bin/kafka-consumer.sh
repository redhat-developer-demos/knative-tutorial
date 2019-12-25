#!/bin/bash
set -e 

trap '{ echo "" ; exit 1; }' INT

KAFKA_TOPIC=${1:-'my-topic'}

kubectl -n kafka run kafka-consumer -ti \
  --image=strimzi/kafka:0.15.0-kafka-2.3.1 \
  --rm=true --restart=Never \
  -- bin/kafka-console-consumer.sh \
  --bootstrap-server my-cluster-kafka-bootstrap:9092 \
  --topic $KAFKA_TOPIC --from-beginning
