# Azure Key Vault Secrets Configuration

## Overview

Sensitive configuration values have been moved from Bicep parameters to Azure Key Vault references. This document outlines the required secrets for each environment.

## Required Secrets by Environment

### Development Environment Secrets

These will be automatically seeded by CI/CD from GitHub Secrets:

```bash
# Key Vault: sportiverse-kv-dev-{token}
JWT_SECRET: "development-jwt-secret-here"
PAYPAL_CLIENT_ID: "sandbox-paypal-client-id"
PAYPAL_APP_SECRET: "sandbox-paypal-app-secret"
MONGODB_PASSWORD: "{cosmos-dev-primary-key}"
```

### Production Environment Secrets

These must be manually seeded by administrators:

```bash
# Key Vault: sportiverse-kv-prod-{token}
JWT_SECRET: "production-jwt-secret-here"
PAYPAL_CLIENT_ID: "live-paypal-client-id"
PAYPAL_APP_SECRET: "live-paypal-app-secret"
MONGODB_PASSWORD: "{cosmos-prod-primary-key}"
```

## App Settings Configuration

The WebAPI App Service now uses Key Vault references for sensitive values:

```json
{
  "JWT_SECRET": "@Microsoft.KeyVault(VaultName={vault-name};SecretName=JWT_SECRET)",
  "PAYPAL_CLIENT_ID": "@Microsoft.KeyVault(VaultName={vault-name};SecretName=PAYPAL_CLIENT_ID)",
  "PAYPAL_APP_SECRET": "@Microsoft.KeyVault(VaultName={vault-name};SecretName=PAYPAL_APP_SECRET)",
  "MONGODB_PASSWORD": "@Microsoft.KeyVault(VaultName={vault-name};SecretName=MONGODB_PASSWORD)"
}
```

## Benefits

✅ **No secrets in code/templates** - All sensitive values stored securely in Key Vault
✅ **Environment isolation** - Separate Key Vaults prevent cross-environment access  
✅ **Managed identity access** - App Services use system-assigned identities to fetch secrets
✅ **Automatic rotation support** - Key Vault references automatically pick up rotated secrets
✅ **Audit logging** - All secret access is logged for compliance

## Next Steps

1. **Deploy infrastructure** - Key Vault and role assignments will be created
2. **Seed development secrets** - CI/CD will populate dev Key Vault from GitHub Secrets
3. **Manually seed production secrets** - Use Azure CLI/Portal for production values
4. **Configure CI/CD** - Update workflows to set Key Vault references in app settings

## Manual Secret Seeding Commands

For production environment (replace vault name and values):

```bash
# Authenticate to Azure
az login

# Set secrets in production Key Vault
VAULT_NAME="sportiverse-kv-prod-xyz123"
az keyvault secret set --vault-name "$VAULT_NAME" --name "JWT_SECRET" --value "your-production-jwt-secret"
az keyvault secret set --vault-name "$VAULT_NAME" --name "PAYPAL_CLIENT_ID" --value "your-live-paypal-client-id"
az keyvault secret set --vault-name "$VAULT_NAME" --name "PAYPAL_APP_SECRET" --value "your-live-paypal-secret"
az keyvault secret set --vault-name "$VAULT_NAME" --name "MONGODB_PASSWORD" --value "your-cosmos-prod-key"
```
