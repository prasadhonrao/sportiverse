docker build -t prasadhonrao/sportiverse-webapi .
docker push prasadhonrao/sportiverse-webapi

az login

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az account set --subscription $SUBSCRIPTION_ID

az webapp config container set \
  --name sportiverse-webapi \
  --resource-group sportiverse-rg \
  --container-image-name "prasadhonrao/sportiverse-webapi:latest" \
  --container-registry-url "https://index.docker.io/v1/"

az webapp restart --name sportiverse-webapi --resource-group sportiverse-rg