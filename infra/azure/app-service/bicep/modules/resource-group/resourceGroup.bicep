// Resource Group Infrastructure Module
// This module orchestrates all resources within a resource group scope
// It creates the App Service Plan, Cosmos DB, and both App Services
targetScope = 'resourceGroup'

// Parameters
@description('Location for all resources')
param location string = resourceGroup().location

@description('Application name prefix')
param appName string

@description('Environment name')
param environmentName string

@description('Resource token for unique naming')
param resourceToken string

@description('SKU for the App Service Plan')
param appServicePlanSku string

@description('Node.js version for the applications')
param nodeVersion string

@description('Enable zone redundancy for Cosmos DB')
param enableZoneRedundancy bool

@description('PayPal API URL (sandbox or production)')
param paypalApiUrl string

@description('Tags to apply to all resources')
param tags object

// Module: App Service Plan
module appServicePlan '../app-service/appServicePlan.bicep' = {
  name: 'appServicePlan-${resourceToken}'
  params: {
    name: '${appName}-plan-${environmentName}-${resourceToken}'
    location: location
    sku: appServicePlanSku
    tags: tags
  }
}

// Module: Key Vault
module keyVault '../security/keyVault.bicep' = {
  name: 'keyVault-${resourceToken}'
  params: {
    name: '${appName}-kv-${environmentName}-${resourceToken}'
    location: location
    enablePurgeProtection: environmentName == 'prod' ? true : false  // Enable for production
    tags: union(tags, {
      'sportiverse-component': 'keyvault'
      'sportiverse-service-type': 'secrets'
    })
  }
}

// Module: Cosmos DB
module cosmosDb '../database/cosmosDb.bicep' = {
  name: 'cosmosDb-${resourceToken}'
  params: {
    accountName: '${appName}-cosmosdb-${environmentName}-${resourceToken}'
    location: location
    databaseName: 'sportiverse-db'
    enableZoneRedundancy: enableZoneRedundancy
    tags: union(tags, {
      'sportiverse-component': 'database'
      'sportiverse-service-type': 'cosmosdb'
    })
  }
}

// Module: Web App (Frontend) - deployed first to get hostname for API CORS
module webApp '../app-service/webApp.bicep' = {
  name: 'webApp-${resourceToken}'
  params: {
    name: '${appName}-webapp-${environmentName}-${resourceToken}'
    location: location
    appServicePlanId: appServicePlan.outputs.id
    nodeVersion: nodeVersion
    apiUrl: '${appName}-api-${environmentName}-${resourceToken}.azurewebsites.net'
    tags: union(tags, {
      'sportiverse-component': 'webapp'
      'sportiverse-service-type': 'frontend'
    })
  }
}

// Module: Web API App Service
module webApi '../app-service/webApi.bicep' = {
  name: 'webApi-${resourceToken}'
  params: {
    name: '${appName}-api-${environmentName}-${resourceToken}'
    location: location
    appServicePlanId: appServicePlan.outputs.id
    nodeVersion: nodeVersion
    cosmosDbAccountName: cosmosDb.outputs.accountName
    paypalApiUrl: paypalApiUrl
    webAppUrl: webApp.outputs.defaultHostName
    keyVaultName: keyVault.outputs.name
    tags: union(tags, {
      'sportiverse-component': 'api'
      'sportiverse-service-type': 'webapi'
    })
  }
}

// Update Web App with correct API URL after API is deployed
module webAppUpdate '../app-service/webApp.bicep' = {
  name: 'webAppUpdate-${resourceToken}'
  params: {
    name: '${appName}-webapp-${environmentName}-${resourceToken}'
    location: location
    appServicePlanId: appServicePlan.outputs.id
    nodeVersion: nodeVersion
    apiUrl: webApi.outputs.defaultHostName
    tags: tags
  }
}

// Role assignments for Key Vault access
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User

// Grant WebAPI access to Key Vault
resource webApiKeyVaultRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.name, webApi.name, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: webApi.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// Grant WebApp access to Key Vault (if needed for runtime config)
resource webAppKeyVaultRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.name, webAppUpdate.name, keyVaultSecretsUserRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: webAppUpdate.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
@description('Web App URL')
output webAppUrl string = 'https://${webAppUpdate.outputs.defaultHostName}'

@description('API URL')
output apiUrl string = 'https://${webApi.outputs.defaultHostName}'

@description('Cosmos DB Account Name')
output cosmosDbAccountName string = cosmosDb.outputs.accountName

@description('Cosmos DB Connection String (use with caution)')
@secure()
output cosmosDbConnectionString string = cosmosDb.outputs.primaryConnectionString

@description('Key Vault Name')
output keyVaultName string = keyVault.outputs.name

@description('Key Vault URI')
output keyVaultUri string = keyVault.outputs.vaultUri

@description('Web API Principal ID')
output webApiPrincipalId string = webApi.outputs.principalId

@description('Web App Principal ID')
output webAppPrincipalId string = webAppUpdate.outputs.principalId
