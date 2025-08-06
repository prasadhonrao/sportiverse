#!/bin/bash

source ../utils/functions.sh

# Define variables
subscription_name="" 
resource_group_name="sportiverse-rg" 
location="uksouth"
cluster_name="sportiverse-aks-cluster"
system_node_count="1"
linux_node_count="3"
windows_node_count="1"


# Check if all variables are set
check_variable "$subscription_name" "subscription_name"
check_variable "$resource_group_name" "resource_group_name"
check_variable "$location" "location"
check_variable "$cluster_name" "cluster_name"
check_variable "$system_node_count" "system_node_count"
check_variable "$linux_node_count" "linux_node_count"
check_variable "$windows_node_count" "windows_node_count"

# Log into the Azure subscription
az login
az account set --subscription $subscription_name

# Create a resource group for the services we're going to create
az group create --name $resource_group_name --location $location

# Create an AKS managed cluster. 
az aks create \
    --resource-group $resource_group_name \
    --name $cluster_name \
    --location $location \
    --node-count $system_node_count \
    --load-balancer-sku standard \
    --windows-admin-username azure \
    --windows-admin-password Test@0123456789 \
    --network-plugin azure \
    --generate-ssh-keys

# Add a Linux node pool
az aks nodepool add \
    --resource-group $resource_group_name \
    --cluster-name $cluster_name \
    --os-type Linux \
    --name lpool \
    --node-count $linux_node_count

# Add a Windows node pool
az aks nodepool add \
    --resource-group $resource_group_name \
    --cluster-name $cluster_name \
    --os-type Windows \
    --name wpool \
    --node-count $windows_node_count

# Get our cluster credentials and merge the configuration into our existing config file.
# This will allow us to connect to this system remotely using certificate-based user authentication.
az aks get-credentials --resource-group $resource_group_name --name $cluster_name

# List our currently available contexts
kubectl config get-contexts

# Set our current context to the Azure context
kubectl config use-context $cluster_name

