#!/bin/sh

SCRIPT_DIR="$( dirname -- "$0"; )"
export TUTORIAL_HOME=$SCRIPT_DIR/../
DNS_DOMAIN=nip.io
KNATIVE_EVENTING_KAFKA_VERSION=v1.8.1
KNATIVE_SERVING_VERSION=v1.8.3
KNATIVE_EVENTING_VERSION=v1.8.5
MINIKUBE_PROFILE=knativetutorial
KOURIER_VERSION=v1.8.1
STRIMZI_OP_VERSION=0.32.0

function confirm() {
   read -p "press enter to proceed or 'Ctrl+c' to cancel" -n 1 -r
   echo
}

echo "
=========================================
This script assumes you have Minikube properly installed and will automatically install and configure: 

 * Knative (Serving and Eventing), 
 * Kafka Cluster (using Strimzi Operator), 
 * Kourier (Knative Serving) Ingress (a lightweight alternative for the Istio ingress), 
 * Contour (Kubernetes) Ingress, 
 * Nexus (Maven Repo Manager),
 * Camel-K Operator

on your local active cluster instance.
=========================================
"
confirm

echo
echo ">>> Check Minikube status"
echo
minikube -p $MINIKUBE_PROFILE status
if [ $? -eq 0 ]; then
    echo "Ok!"
else
    echo "Minikube profile $MINIKUBE_PROFILE not started."
    echo "Make sure to create and start it first!"
    exit 1
fi

echo
echo ">>> Install Knative Serving ($KNATIVE_SERVING_VERSION) and Eventing ($KNATIVE_EVENTING_VERSION) CRDs..."
confirm
kubectl apply \
  --filename https://github.com/knative/serving/releases/download/knative-$KNATIVE_SERVING_VERSION/serving-crds.yaml \
  --filename https://github.com/knative/eventing/releases/download/knative-$KNATIVE_EVENTING_VERSION/eventing-crds.yaml

echo
echo "Serving CRDs"
kubectl api-resources --api-group='serving.knative.dev'
echo
echo "Messaging CRDs"
kubectl api-resources --api-group='messaging.knative.dev'
echo
echo "Eventing CRDs"
kubectl api-resources --api-group='eventing.knative.dev'
echo
echo "Sources CRDs"
kubectl api-resources --api-group='sources.knative.dev'

echo
echo "----"
echo ">>> Install Knative Serving ($KNATIVE_SERVING_VERSION)..."
confirm
kubectl apply \
  --filename https://github.com/knative/serving/releases/download/knative-$KNATIVE_SERVING_VERSION/serving-core.yaml

sleep 2

echo
echo "Knative deploy status"
kubectl rollout status deploy controller -n knative-serving
kubectl rollout status deploy activator -n knative-serving
kubectl rollout status deploy autoscaler -n knative-serving
kubectl rollout status deploy webhook -n knative-serving
echo
kubectl get pods -n knative-serving

echo
echo "----"
echo ">>> Install Kourier Ingress Gateway ($KOURIER_VERSION)"
confirm
kubectl apply \
  --filename https://github.com/knative/net-kourier/releases/download/knative-$KOURIER_VERSION/kourier.yaml

sleep 5

echo
echo "Kourier deployment status"
kubectl rollout status deploy 3scale-kourier-gateway -n kourier-system
kubectl rollout status deploy 3scale-kourier-control -n knative-serving
echo
kubectl get pods --all-namespaces -l 'app in(3scale-kourier-gateway,3scale-kourier-control)'

echo
echo "configure Knative serving to use Kourier as the ingress by patching 'configmap/config-network'"
kubectl patch configmap/config-network \
  -n knative-serving \
  --type merge \
  -p '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

echo
echo "----"
echo ">>> Install and Configure Contour Ingress Controller"
confirm
kubectl apply \
  --filename https://projectcontour.io/quickstart/contour.yaml

sleep 2
echo
kubectl get pods -n projectcontour

echo
echo ">>> Create an Ingress to Kourier Ingress Gateway..."
cat <<EOF | kubectl apply -n kourier-system -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kourier-ingress
  namespace: kourier-system
spec:
  rules:
  - http:
     paths:
       - path: /
         pathType: Prefix
         backend:
           service:
             name: kourier
             port:
               number: 80
EOF

echo
echo ">>> Configure Knative to use the kourier-ingress Gateway"
ksvc_domain="\"data\":{\""$(minikube -p $MINIKUBE_PROFILE ip)".$DNS_DOMAIN\": \"\"}"
kubectl patch configmap/config-domain \
    -n knative-serving \
    --type merge \
    -p "{$ksvc_domain}"

echo
echo "----"
echo ">>> Install Knative Eventing ($KNATIVE_EVENTING_VERSION) resources"
confirm
kubectl apply \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-$KNATIVE_EVENTING_VERSION/eventing-core.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-$KNATIVE_EVENTING_VERSION/in-memory-channel.yaml \
  --filename \
  https://github.com/knative/eventing/releases/download/knative-$KNATIVE_EVENTING_VERSION/mt-channel-broker.yaml

echo
echo "Knative Eventing deploy status"
kubectl rollout status deploy eventing-controller -n knative-eventing
kubectl rollout status deploy eventing-webhook  -n knative-eventing
kubectl rollout status deploy imc-controller  -n knative-eventing
kubectl rollout status deploy imc-dispatcher -n knative-eventing
kubectl rollout status deploy mt-broker-controller -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing
kubectl rollout status deploy mt-broker-filter -n knative-eventing

echo
kubectl get pods -n knative-eventing

sleep 3

echo
echo "----"
echo ">>> Create Tutorial Namespace"
confirm
kubectl create namespace knativetutorial
echo
kubens knativetutorial

echo "Minikube Docker env"
eval $(minikube docker-env)

echo
echo "----"
echo ">>> Install Apache Camel K"
confirm
echo
echo "Configure Maven Settings pointing to a local Nexus Instance to be used by the Camel-K Operator..."
kubectl create configmap \
  -n knativetutorial my-camel-k-maven-settings \
  --from-file=settings.xml="$TUTORIAL_HOME/install/utils/camel-k-maven-settings.xml"

echo
echo ">>> Enable image registry addon on Minikube"
minikube -p $MINIKUBE_PROFILE addons enable registry

echo
echo ">>> Install Camel-K Operator..."
kamel install \
  --namespace knativetutorial \
  --olm=false \
  --maven-cli-option="-e" \
  --maven-cli-option="--no-transfer-progress" \
  --maven-cli-option="-Dstyle.color=never" \
  --maven-settings="configmap:my-camel-k-maven-settings/settings.xml" \
  --wait

echo
echo "----"
echo ">>> Deploy Nexus"
confirm
kubectl apply -n knativetutorial -f $TUTORIAL_HOME/install/utils/nexus.yaml

sleep 10
echo
kubectl get -n knativetutorial pods

echo
echo "Get nexus Admin pwd"
export NEXUS_POD=$(kubectl -n knativetutorial get pods \
  -lapp=nexus -ojsonpath='{.items[0].metadata.name}')
kubectl exec $NEXUS_POD -- cat /nexus-data/admin.password
minikube -p $MINIKUBE_PROFILE service -n knativetutorial nexus

echo
echo "----"
echo ">>> Deploy Kafka through Strimzi Operator ($STRIMZI_OP_VERSION)"
confirm
kubectl create namespace kafka

curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/$STRIMZI_OP_VERSION/strimzi-cluster-operator-$STRIMZI_OP_VERSION.yaml \
| sed 's/namespace:.*/namespace: kafka/' \
| kubectl apply -n kafka -f -

echo
kubectl api-resources --api-group='kafka.strimzi.io'

echo
echo ">>> Create a Kafka Cluster"
kubectl -n kafka apply -f $TUTORIAL_HOME/eventing/kafka-broker-my-cluster.yaml

echo
kubectl get pods -n kafka

echo
echo ">>> Deploy Knative Eventing KafkaSource ($KNATIVE_EVENTING_KAFKA_VERSION)"
kubectl apply -f https://github.com/knative-sandbox/eventing-kafka/releases/download/knative-$KNATIVE_EVENTING_KAFKA_VERSION/source.yaml

echo
echo ">>> Deploy a Knative Kafka Channel"
curl -L "https://github.com/knative-sandbox/eventing-kafka/releases/download/knative-$KNATIVE_EVENTING_KAFKA_VERSION/channel-consolidated.yaml" \
 | sed 's/REPLACE_WITH_CLUSTER_URL/my-cluster-kafka-bootstrap.kafka:9092/' \
 | kubectl apply --filename -

echo
kubectl get pods -n knative-eventing
kn source list-types

echo
echo "----"
echo ">>> Using Kafka Channel as Default Knative Channel"
kubectl apply -f $TUTORIAL_HOME/eventing/default-channel-config.yaml

echo
echo "All set!"