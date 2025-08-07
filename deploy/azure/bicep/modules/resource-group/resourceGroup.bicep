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

@description('PayPal Client ID for payment processing')
@secure()
param paypalClientId string

@description('PayPal App Secret for payment processing')
@secure()
param paypalAppSecret string

@description('PayPal API URL (sandbox or production)')
param paypalApiUrl string

@description('JWT Secret for authentication')
@secure()
param jwtSecret string

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

// Module: Cosmos DB
module cosmosDb '../database/cosmosDb.bicep' = {
  name: 'cosmosDb-${resourceToken}'
  params: {
    accountName: '${appName}-cosmosdb-${environmentName}-${resourceToken}'
    location: location
    databaseName: 'sportiverse-db'
    enableZoneRedundancy: enableZoneRedundancy
    tags: tags
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
    tags: tags
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
    cosmosDbPrimaryKey: cosmosDb.outputs.primaryKey
    jwtSecret: jwtSecret
    paypalClientId: paypalClientId
    paypalAppSecret: paypalAppSecret
    paypalApiUrl: paypalApiUrl
    webAppUrl: webApp.outputs.defaultHostName
    tags: tags
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
