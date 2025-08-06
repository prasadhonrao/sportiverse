#!/bin/bash

# Ensure the correct URI is passed as an argument to the update-config.sh script
BASE_API_URI=$1

if [ -z "$BASE_API_URI" ]; then
  echo "Error: BASE_API_URI is not provided. Please pass it as the first argument."
  exit 1
fi

# Azure Web App details
RESOURCE_GROUP="sportiverse-rg"
WEB_APP_NAME="sportiverse-webapp"
REGISTRY_NAME="prasadhonrao"
IMAGE_NAME="sportiverse-webapp"

# Call the update-config.sh script to update the value of BASE_API_URI
./update-config.sh "$BASE_API_URI"

# Build and push the Docker image
docker build -t $REGISTRY_NAME/$IMAGE_NAME:latest .
docker push $REGISTRY_NAME/$IMAGE_NAME:latest

# Log in to Azure
az login

# Ensure the Azure CLI is targeting the correct subscription
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription $SUBSCRIPTION_ID

# Update the Azure Web App to use the latest Docker image
az webapp config container set \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name "$REGISTRY_NAME/$IMAGE_NAME:latest" \
  --docker-registry-server-url "https://index.docker.io/v1/"

# Restart the Azure Web App to apply changes
az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP

echo "Deployment to Azure Web App ($WEB_APP_NAME) completed successfully!"