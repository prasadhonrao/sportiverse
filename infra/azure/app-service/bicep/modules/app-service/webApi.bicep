@description('Name of the Web API App Service')
param name string

@description('Location for the Web API App Service')
param location string = resourceGroup().location

@description('App Service Plan ID')
param appServicePlanId string

@description('Node.js version')
param nodeVersion string

@description('Cosmos DB account name (extracted from connection string)')
param cosmosDbAccountName string

@description('Cosmos DB primary key')
@secure()
param cosmosDbPrimaryKey string

@description('JWT Secret')
@secure()
param jwtSecret string

@description('PayPal Client ID')
@secure()
param paypalClientId string

@description('PayPal App Secret')
@secure()
param paypalAppSecret string

@description('PayPal API URL (sandbox or production)')
param paypalApiUrl string

@description('Web App URL for CORS')
param webAppUrl string

@description('Tags to apply to the resource')
param tags object = {}

// Web API App Service
resource webApiApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanId
    reserved: true
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'NODE|${nodeVersion}'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      use32BitWorkerProcess: false
      cors: {
        allowedOrigins: [
          'https://${webAppUrl}'
          'http://localhost:3000' // For local development
        ]
        supportCredentials: true
      }
      appSettings: [
        {
          name: 'PORT'
          value: '5000'
        }
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'ALLOWED_ORIGINS'
          value: 'https://${webAppUrl}'
        }
        {
          name: 'MONGODB_CONNECTION_SCHEME'
          value: 'mongodb'
        }
        {
          name: 'MONGODB_HOST'
          value: '${cosmosDbAccountName}.mongo.cosmos.azure.com'
        }
        {
          name: 'MONGODB_PORT'
          value: '10255'
        }
        {
          name: 'MONGODB_USERNAME'
          value: cosmosDbAccountName
        }
        {
          name: 'MONGODB_PASSWORD'
          value: cosmosDbPrimaryKey
        }
        {
          name: 'MONGODB_DB_NAME'
          value: 'sportiverse-db'
        }
        {
          name: 'MONGODB_DB_PARAMS'
          value: 'ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${cosmosDbAccountName}@'
        }
        {
          name: 'JWT_SECRET'
          value: jwtSecret
        }
        {
          name: 'PAYPAL_CLIENT_ID'
          value: paypalClientId
        }
        {
          name: 'PAYPAL_APP_SECRET'
          value: paypalAppSecret
        }
        {
          name: 'PAYPAL_API_URL'
          value: paypalApiUrl
        }
        {
          name: 'PAGINATION_LIMIT'
          value: '10'
        }
        {
          name: 'UPLOAD_PATH'
          value: '/uploads'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '18.20.0'
        }
      ]
      connectionStrings: []
    }
  }
}

// App Service configuration for startup command
resource webApiConfig 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: webApiApp
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: []
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: true
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$${name}'
    linuxFxVersion: 'NODE|${nodeVersion}'
    alwaysOn: true
  }
}

// Outputs
@description('Web API App Service name')
output name string = webApiApp.name

@description('Web API App Service ID')
output id string = webApiApp.id

@description('Web API default hostname')
output defaultHostName string = webApiApp.properties.defaultHostName

@description('Web API possible outbound IP addresses')
output possibleOutboundIpAddresses string = webApiApp.properties.possibleOutboundIpAddresses
