#!bin/bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f role.yaml
kubectl apply -f serviceaccount.yaml
kubectl delete -f storageclass.yaml
kubectl apply -f storageclass.yaml # Storage class fields are immutable, so we need to delete and reapply
kubectl apply -f statefulset.yaml
kubectl apply -f service.yaml
