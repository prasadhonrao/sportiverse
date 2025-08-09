@description('Key Vault name')
param name string

@description('Location for the Key Vault')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('Enable soft delete (recommended for production)')
param enableSoftDelete bool = true

@description('Soft delete retention in days')
param softDeleteRetentionInDays int = 7

@description('Enable purge protection (recommended for production)')
param enablePurgeProtection bool = false

// Key Vault with RBAC authorization
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true  // Use RBAC instead of access policies
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
  }
}

// Outputs
@description('Key Vault name')
output name string = keyVault.name

@description('Key Vault resource ID')
output id string = keyVault.id

@description('Key Vault URI')
output vaultUri string = keyVault.properties.vaultUri
