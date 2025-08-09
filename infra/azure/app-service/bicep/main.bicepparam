using 'main.bicep'

// Environment configuration
param environmentName = 'dev'
param location = 'eastus'
param appName = 'sportiverse'
param resourceGroupName = 'sportiverse-rg-dev'
param appServicePlanSku = 'B1'
param nodeVersion = '22-lts'
param enableZoneRedundancy = false

// PayPal API configuration (non-sensitive)
param paypalApiUrl = readEnvironmentVariable('PAYPAL_API_URL', 'https://api-m.sandbox.paypal.com')

// Note: Sensitive values (JWT_SECRET, PAYPAL_CLIENT_ID, PAYPAL_APP_SECRET, MONGODB_PASSWORD) 
// are now stored in Azure Key Vault and referenced via app settings
