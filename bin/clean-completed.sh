#!/bin/bash

kubectl delete pods --field-selector=status.phase=Succeeded 
kubectl delete pods --field-selector=status.phase=Failed