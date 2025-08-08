@description('Name of the Web App App Service')
param name string

@description('Location for the Web App App Service')
param location string = resourceGroup().location

@description('App Service Plan ID')
param appServicePlanId string

@description('Node.js version')
param nodeVersion string

@description('API URL for the backend')
param apiUrl string

@description('Tags to apply to the resource')
param tags object = {}

// Web App (Frontend) App Service
resource webApp 'Microsoft.Web/sites@2024-04-01' = {
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
      appSettings: [
        {
          name: 'PORT'
          value: '3000'
        }
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'API_BASE_URL'
          value: 'https://${apiUrl}'
        }
        {
          name: 'GENERATE_SOURCEMAP'
          value: 'false'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '22.11.0'
        }
      ]
      connectionStrings: []
    }
  }
}

// App Service configuration
resource webAppConfig 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: webApp
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'index.html'
    ]
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
@description('Web App name')
output name string = webApp.name

@description('Web App ID')
output id string = webApp.id

@description('Web App default hostname')
output defaultHostName string = webApp.properties.defaultHostName

@description('Web App possible outbound IP addresses')
output possibleOutboundIpAddresses string = webApp.properties.possibleOutboundIpAddresses
