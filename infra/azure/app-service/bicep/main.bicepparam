using 'main.bicep'

// Environment configuration
param environmentName = 'dev'
param location = 'eastus'
param appName = 'sportiverse'
param resourceGroupName = 'sportiverse-rg-dev'
param appServicePlanSku = 'B1'
param nodeVersion = '18-lts'
param enableZoneRedundancy = false

// Secure parameters - these should be provided at deployment time
param paypalClientId = readEnvironmentVariable('PAYPAL_CLIENT_ID', 'your-paypal-client-id-here')
param paypalAppSecret = readEnvironmentVariable('PAYPAL_APP_SECRET', 'your-paypal-app-secret-here')
param paypalApiUrl = readEnvironmentVariable('PAYPAL_API_URL', 'https://api-m.sandbox.paypal.com')
param jwtSecret = readEnvironmentVariable('JWT_SECRET', 'your-jwt-secret-here')
