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

// Secret parameters (optional - can be seeded later via deployment script)
@secure()
@description('PayPal Client ID for payment processing')
param paypalClientId string = ''

@secure()
@description('PayPal App Secret for payment processing')
param paypalAppSecret string = ''

@secure()
@description('JWT Secret for token signing')
param jwtSecret string = ''

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

// Key Vault Secrets (only create if values are provided)
resource paypalClientIdSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(paypalClientId)) {
  parent: keyVault
  name: 'PAYPAL-CLIENT-ID'
  properties: {
    value: paypalClientId
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
}

resource paypalAppSecretSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(paypalAppSecret)) {
  parent: keyVault
  name: 'PAYPAL-APP-SECRET'
  properties: {
    value: paypalAppSecret
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
  }
}

resource jwtSecretSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(jwtSecret)) {
  parent: keyVault
  name: 'JWT-SECRET'
  properties: {
    value: jwtSecret
    contentType: 'text/plain'
    attributes: {
      enabled: true
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
