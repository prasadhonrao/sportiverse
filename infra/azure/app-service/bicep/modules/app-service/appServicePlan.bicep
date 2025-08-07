@description('Name of the App Service Plan')
param name string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('SKU for the App Service Plan')
param sku string

@description('Tags to apply to the resource')
param tags object = {}

// App Service Plan resource
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
  }
  sku: {
    name: sku
  }
}

// Outputs
@description('App Service Plan ID')
output id string = appServicePlan.id

@description('App Service Plan name')
output name string = appServicePlan.name
