# Azure Service Principal Setup for GitHub Actions

This document explains how to set up the Azure Service Principal required for the GitHub Actions CI/CD workflows.

## 🎯 Overview

The `AZURE_SERVICE_PRINCIPAL` secret is required for GitHub Actions to authenticate with Azure and deploy your infrastructure and applications. This needs to be set up **before** running your CI/CD workflows.

## 🔐 Security Principles

- **Least Privilege**: Service principal gets only the permissions needed
- **Environment Isolation**: Separate service principals per environment (dev/staging/prod)
- **Credential Rotation**: Easy to rotate credentials when needed

## 📋 Prerequisites

Before running the setup script, ensure you have:

1. **Azure CLI installed** and logged in with appropriate permissions
2. **Subscription Owner or Contributor role** in your target Azure subscription
3. **Global Administrator role** (for API consent) or someone who can grant it
4. **GitHub repository** where you'll add the secrets
5. **GitHub CLI installed** and authenticated (optional, for automatic secret setup)

### GitHub CLI Setup (Optional but Recommended)

For automatic secret management, install and authenticate GitHub CLI:

```bash
# Install GitHub CLI (choose your platform)
# macOS: brew install gh
# Windows: winget install GitHub.cli
# Linux: See https://cli.github.com/

# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status
```

## 🚀 Setup Methods

### Method 1: Simplified PowerShell Script (Recommended)

The PowerShell script provides the most reliable way to create service principals and automatically add secrets to GitHub:

```powershell
# Navigate to the scripts directory
cd scripts

# Authenticate with GitHub CLI (one-time setup)
gh auth login

# Run for development environment
.\simple-sp-setup.ps1 "your-subscription-id" "dev"

# Run for production environment
.\simple-sp-setup.ps1 "your-subscription-id" "prod"
```

### Method 2: Bash Script (Alternative)

If you prefer bash but experience path issues with Git Bash on Windows, try using WSL or Linux:

```bash
# Navigate to the scripts directory
cd scripts

# Make the script executable
chmod +x simple-sp-setup.sh

# Authenticate with GitHub CLI (one-time setup)
gh auth login

# Run for development environment
./simple-sp-setup.sh "your-subscription-id" "dev"

# Run for production environment
./simple-sp-setup.sh "your-subscription-id" "prod"
```

**Benefits of using the PowerShell script:**

- ✅ **No path conversion issues**: Works reliably on Windows without Git Bash path mangling
- ✅ **Automatically adds secrets**: Integrates with GitHub CLI to add secrets directly
- ✅ **Environment-specific naming**: Handles dev/staging/prod secret naming automatically
- ✅ **Immediate feedback**: Shows success/failure status immediately
- ✅ **Simple and reliable**: Uses the proven `az ad sp create-for-rbac` approach

### Method 3: Manual Azure CLI Commands

If you prefer manual setup without GitHub CLI integration:

```bash
# Set your subscription
az account set --subscription "your-subscription-id"

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "sportiverse-cicd-dev" \
  --role contributor \
  --scopes "/subscriptions/your-subscription-id" \
  --years 1
```

## 🔑 GitHub Secrets Configuration

### Automatic Setup (Recommended)

If you used the PowerShell script with GitHub CLI, the secret is automatically added! You should see:

```text
✅ Secret 'AZURE_SERVICE_PRINCIPAL' added to GitHub successfully!
✅ Setup complete!
```

### Manual Setup (Fallback)

If automatic setup failed or you prefer manual configuration:

### Single JSON Secret (Recommended)

Add this secret to your GitHub repository:

**Secret Name:** `AZURE_SERVICE_PRINCIPAL`

**Secret Value:**

```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "your-secret-here",
  "subscriptionId": "87654321-4321-4321-4321-210987654321",
  "tenantId": "11111111-2222-3333-4444-555555555555"
}
```

### Alternative: Individual Secrets

If you prefer separate secrets:

- `AZURE_CLIENT_ID`: 12345678-1234-1234-1234-123456789012
- `AZURE_CLIENT_SECRET`: your-secret-here
- `AZURE_SUBSCRIPTION_ID`: 87654321-4321-4321-4321-210987654321
- `AZURE_TENANT_ID`: 11111111-2222-3333-4444-555555555555

## 🏗️ Workflow Integration

Your workflow is already configured to use the service principal:

```yaml
# Login using the JSON secret (current approach)
az login --service-principal \
  --username ${{ fromJson(secrets.AZURE_SERVICE_PRINCIPAL).clientId }} \
  --password ${{ fromJson(secrets.AZURE_SERVICE_PRINCIPAL).clientSecret }} \
  --tenant ${{ fromJson(secrets.AZURE_SERVICE_PRINCIPAL).tenantId }}

# Alternative: Individual secrets
az login --service-principal \
  --username ${{ secrets.AZURE_CLIENT_ID }} \
  --password ${{ secrets.AZURE_CLIENT_SECRET }} \
  --tenant ${{ secrets.AZURE_TENANT_ID }}
```

## 🔄 Environment-Specific Setup

For production-ready deployments, create separate service principals with automatic GitHub integration:

```powershell
# Development environment
.\simple-sp-setup.ps1 "sub-id" "dev"

# Staging environment
.\simple-sp-setup.ps1 "sub-id" "staging"

# Production environment
.\simple-sp-setup.ps1 "sub-id" "prod"
```

The script automatically creates environment-specific secret names:

- `AZURE_SERVICE_PRINCIPAL` (for dev environment)
- `AZURE_SERVICE_PRINCIPAL_STAGING` (for staging environment)
- `AZURE_SERVICE_PRINCIPAL_PROD` (for production environment)

## ✅ Verification

### Automatic Verification

If you used the PowerShell script with GitHub CLI, test your setup by triggering a workflow:

```bash
# Test the workflow directly
gh workflow run webapi-deploy.yml

# Or push changes to trigger automatically
git add .
git commit -m "test: trigger workflow"
git push
```

### Manual Verification

Test your service principal manually:

```bash
# Test login
az login --service-principal \
  --username "your-client-id" \
  --password "your-client-secret" \
  --tenant "your-tenant-id"

# Test Resource Graph access (required for dynamic discovery)
az graph query -q "Resources | limit 1"

# Test subscription access
az account show
```

## 🔐 Security Best Practices

1. **Rotate Credentials Regularly**: Use the reset command to generate new secrets
2. **Monitor Usage**: Review Azure Activity Logs for service principal activities
3. **Least Privilege**: Only grant permissions needed for deployment
4. **Environment Isolation**: Use separate service principals per environment
5. **Audit Access**: Regularly review service principal permissions

## 🛠️ Troubleshooting

### Common Issues

**Git Bash Path Issues on Windows:**

- Use PowerShell script instead: `.\simple-sp-setup.ps1`
- Or use Windows Subsystem for Linux (WSL) for bash scripts
- Avoid Git Bash for Azure CLI commands with subscription paths

**Permission Denied Errors:**

- Ensure the service principal has Contributor role on the subscription
- Check if Resource Graph permissions are granted

**API Permission Issues:**

- Grant admin consent for Microsoft Graph API permissions
- Wait a few minutes after granting permissions

**Workflow Authentication Failures:**

- Verify the JSON format in GitHub secrets
- Ensure no extra spaces or line breaks in secret values

**GitHub CLI Issues:**

- Ensure GitHub CLI is installed: `gh --version`
- Check authentication status: `gh auth status`
- Re-authenticate if needed: `gh auth login`
- Verify repository access: `gh repo view`

**Subscription Path Mangling:**

- This is a known issue with Git Bash on Windows
- Use PowerShell: `.\simple-sp-setup.ps1` instead
- Or use CMD/PowerShell for Azure CLI commands

### Reset Service Principal Credentials

If you need to rotate credentials:

```bash
az ad sp credential reset \
  --id "your-client-id" \
  --sdk-auth
```

## 📚 Additional Resources

- [Azure Service Principals Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
- [GitHub Actions Azure Authentication](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [Azure Resource Graph Permissions](https://docs.microsoft.com/en-us/azure/governance/resource-graph/overview)
