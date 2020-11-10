#!/bin/bash

echo "Deleting completed pods"
kubectl delete pods --field-selector=status.phase=Succeeded 

echo "Deleting failed pods"
kubectl delete pods --field-selector=status.phase=Failed
