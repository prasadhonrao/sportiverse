#!/bin/bash

source ../utils/functions.sh

# Define variables
subscription_name="" 
resource_group_name="sportiverse-rg" 
cluster_name="sportiverse-aks-cluster"

check_variable "$subscription_name" "subscription_name"
check_variable "$resource_group_name" "resource_group_name"
check_variable "$cluster_name" "cluster_name"

# Log into the Azure subscription
az login
az account set --subscription $subscription_name

# Clean up the AKS cluster when you're done 
az aks delete --resource-group $resource_group_name --name $cluster_name --yes --no-wait

# Clean up the resource group when you're done 
az group delete --name $resource_group_name --yes --no-wait

