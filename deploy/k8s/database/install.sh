#!bin/bash
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f role.yaml
kubectl apply -f serviceaccount.yaml
# kubectl apply -f pv.yaml
# kubectl apply -f pvc.yaml
kubectl apply -f storageclass.yaml
kubectl apply -f statefulset.yaml

# Wait for PVC to be bound
# echo "Waiting for PVC to be bound..."
# while [[ $(kubectl get pvc sportiverse-pvc -n sportiverse-namespace -o jsonpath='{.status.phase}') != "Bound" ]]; do
#   echo -n "."
#   sleep 1
# done
# echo "PVC is bound."

# kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml