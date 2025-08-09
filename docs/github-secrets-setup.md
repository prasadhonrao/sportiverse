# GitHub Secrets Configuration

This document outlines the GitHub Secrets that need to be configured in your repository for the CI/CD workflows to function properly.

## Required Repository Secrets

Navigate to your GitHub repository → Settings → Secrets and variables → Actions to configure these secrets.

### **Azure Authentication**

```
AZURE_SERVICE_PRINCIPAL
```

**Value**: JSON object with Azure service principal credentials

```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "tenantId": "your-tenant-id",
  "subscriptionId": "your-subscription-id"
}
```

### **Development Environment Secrets**

These are used to automatically seed the development Key Vault:

```
DEV_JWT_SECRET
```

**Value**: A secure random string for JWT token signing in development
**Example**: `dev-jwt-secret-randomly-generated-12345`

```
DEV_PAYPAL_CLIENT_ID
```

**Value**: PayPal sandbox client ID for development
**Example**: `sandbox-paypal-client-id-here`

```
DEV_PAYPAL_APP_SECRET
```

**Value**: PayPal sandbox app secret for development  
**Example**: `sandbox-paypal-app-secret-here`

## Setting Up GitHub Secrets

### Method 1: GitHub Web Interface

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the name and value from above

### Method 2: GitHub CLI

```bash
# Set Azure service principal (replace with your values)
gh secret set AZURE_SERVICE_PRINCIPAL --body '{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "tenantId": "your-tenant-id",
  "subscriptionId": "your-subscription-id"
}'

# Set development secrets
gh secret set DEV_JWT_SECRET --body "your-dev-jwt-secret-here"
gh secret set DEV_PAYPAL_CLIENT_ID --body "your-sandbox-paypal-client-id"
gh secret set DEV_PAYPAL_APP_SECRET --body "your-sandbox-paypal-secret"
```

## Azure Service Principal Setup

If you don't have an Azure service principal yet, create one:

```bash
# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "sportiverse-github-actions" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth

# This will output the JSON you need for AZURE_SERVICE_PRINCIPAL secret
```

## PayPal Sandbox Setup

1. Go to [PayPal Developer Dashboard](https://developer.paypal.com/developer/applications/)
2. Create a new application for development
3. Use the sandbox Client ID and Secret for the GitHub Secrets
4. For production, you'll manually configure live PayPal credentials in the production Key Vault

## JWT Secret Generation

Generate a secure JWT secret for development:

```bash
# Generate a random 32-character string
openssl rand -base64 32
```

## Security Best Practices

✅ **Development secrets** are stored in GitHub Secrets and automatically seeded to dev Key Vault
✅ **Production secrets** are never stored in GitHub - they must be manually configured in production Key Vault
✅ **Service principal** has minimal required permissions (Contributor on subscription)
✅ **PayPal sandbox** credentials are used for development - separate live credentials for production
✅ **JWT secrets** are environment-specific and randomly generated

## Workflow Integration

Once these secrets are configured:

1. **Infrastructure workflow** will use `AZURE_SERVICE_PRINCIPAL` to authenticate with Azure
2. **Development deployment** will automatically seed dev Key Vault with `DEV_*` secrets
3. **Production deployment** will display manual instructions for setting production secrets
4. **Application workflows** will discover resources by tags (no hardcoded names)

## Troubleshooting

### Common Issues

**Error: "AZURE_SERVICE_PRINCIPAL secret not found"**

- Ensure the secret is named exactly `AZURE_SERVICE_PRINCIPAL` (case-sensitive)
- Verify the JSON format is valid

**Error: "DEV_JWT_SECRET secret not found"**

- Add the development secrets listed above
- The infrastructure workflow will fail on dev secret seeding without these

**Error: "Insufficient permissions"**

- Ensure the service principal has Contributor role on the subscription
- Check that the subscription ID in the secret matches your target subscription

### Validation Commands

Test your Azure service principal:

```bash
# Extract values from your secret JSON
CLIENT_ID="your-client-id"
CLIENT_SECRET="your-client-secret"
TENANT_ID="your-tenant-id"

# Test authentication
az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID
az account show
```

## Next Steps

After configuring these secrets:

1. ✅ Infrastructure workflow can deploy Key Vault and seed development secrets
2. ✅ Ready to create application CI/CD workflows that discover resources by tags
3. ✅ Production secrets still need manual configuration (by design for security)
