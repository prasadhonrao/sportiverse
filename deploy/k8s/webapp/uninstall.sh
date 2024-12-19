#!bin/bash
kubectl delete -f hpa.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f role.yaml
kubectl delete -f serviceaccount.yaml
kubectl delete -f configmap.yaml
