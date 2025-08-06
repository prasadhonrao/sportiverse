#!bin/bash
kubectl apply -f configmap.yaml
kubectl apply -f serviceaccount.yaml
kubectl apply -f role.yaml
kubectl apply -f secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
# kubectl apply -f hpa.yaml

# Port forward service to test API connectivity from local machine
# kubectl port-forward service/sportiverse-webapi-service 5000:5000 -n sportiverse-namespace