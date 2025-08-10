targetScope = 'subscription'

// Parameters
@description('Environment name (e.g., dev, test, prod)')
param environmentName string = 'dev'

@description('Location for all resources')
param location string = deployment().location

@description('Application name prefix')
param appName string = 'sportiverse'

@description('Resource group name')
param resourceGroupName string = '${appName}-rg-${environmentName}'

@description('SKU for the App Service Plan')
@allowed(['B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1v2', 'P2v2', 'P3v2'])
param appServicePlanSku string = 'B1'

@description('Node.js version for the applications')
param nodeVersion string = '22-lts'

@description('Enable zone redundancy for Cosmos DB')
param enableZoneRedundancy bool = false

@description('PayPal API URL (sandbox or production)')
param paypalApiUrl string = 'https://api-m.sandbox.paypal.com'

// Secret parameters for Key Vault
@secure()
@description('PayPal Client ID for payment processing')
param paypalClientId string

@secure()
@description('PayPal App Secret for payment processing')
param paypalAppSecret string

@secure()
@description('JWT Secret for token signing')
param jwtSecret string

// Variables
var resourceToken = toLower(uniqueString(subscription().id, resourceGroupName, location))
var tags = {
  Environment: environmentName
  Application: appName
  'Created-By': 'Bicep'
  // Tags for dynamic discovery by CI/CD workflows
  'sportiverse-environment': environmentName
  'sportiverse-project': appName
  'sportiverse-resource-token': resourceToken
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Module: Resource Group deployment (all resources in the resource group)
module resourceGroup 'modules/resource-group/resourceGroup.bicep' = {
  name: 'resourceGroup-${resourceToken}'
  scope: rg
  params: {
    location: location
    appName: appName
    environmentName: environmentName
    resourceToken: resourceToken
    appServicePlanSku: appServicePlanSku
    nodeVersion: nodeVersion
    enableZoneRedundancy: enableZoneRedundancy
    paypalApiUrl: paypalApiUrl
    paypalClientId: paypalClientId
    paypalAppSecret: paypalAppSecret
    jwtSecret: jwtSecret
    tags: tags
  }
}

// Outputs
@description('Web App URL')
output webAppUrl string = resourceGroup.outputs.webAppUrl

@description('API URL')
output apiUrl string = resourceGroup.outputs.apiUrl

@description('Cosmos DB Account Name')
output cosmosDbAccountName string = resourceGroup.outputs.cosmosDbAccountName

@description('Cosmos DB Connection String (use with caution)')
@secure()
output cosmosDbConnectionString string = resourceGroup.outputs.cosmosDbConnectionString

@description('Resource Group Name')
output resourceGroupName string = rg.name

@description('Resource Token')
output resourceToken string = resourceToken

@description('Key Vault Name')
output keyVaultName string = resourceGroup.outputs.keyVaultName

@description('Key Vault URI')
output keyVaultUri string = resourceGroup.outputs.keyVaultUri

// @description('Web API Principal ID')
// output webApiPrincipalId string = resourceGroup.outputs.webApiPrincipalId

// @description('Web App Principal ID')
// output webAppPrincipalId string = resourceGroup.outputs.webAppPrincipalId
