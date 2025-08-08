# Simple Azure Service Principal Setup for GitHub Actions
# Usage: .\simple-sp-setup.ps1 <subscription-id> <environment>

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

# Function to write colored output
function Write-Status($message) { Write-Host "[INFO] $message" -ForegroundColor Blue }
function Write-Success($message) { Write-Host "[SUCCESS] $message" -ForegroundColor Green }
function Write-Warning($message) { Write-Host "[WARNING] $message" -ForegroundColor Yellow }
function Write-Error($message) { Write-Host "[ERROR] $message" -ForegroundColor Red }

$ServicePrincipalName = "sportiverse-cicd-$Environment"

Write-Status "Setting up Service Principal: $ServicePrincipalName"
Write-Status "Subscription: $SubscriptionId"

# Login check
try {
    $null = az account show 2>$null
} catch {
    Write-Error "Not logged into Azure CLI. Please run: az login"
    exit 1
}

# Set subscription
Write-Status "Setting subscription..."
az account set --subscription $SubscriptionId

# Verify subscription is set
$CurrentSub = az account show --query "id" -o tsv 2>$null
if ($CurrentSub -ne $SubscriptionId) {
    Write-Error "Failed to set subscription. Check if subscription ID is correct and you have access."
    Write-Error "Available subscriptions:"
    az account list --query "[].{Name:name, SubscriptionId:id}" -o table
    exit 1
}

Write-Success "Subscription set: $CurrentSub"

# Delete existing service principal if it exists
Write-Status "Checking for existing service principal..."
$ExistingSP = az ad sp list --display-name $ServicePrincipalName --query "[0].appId" -o tsv 2>$null
if ($ExistingSP -and $ExistingSP -ne "null") {
    Write-Warning "Deleting existing service principal: $ExistingSP"
    az ad sp delete --id $ExistingSP
}

# Create service principal
Write-Status "Creating service principal with subscription-level contributor access..."
$SpOutput = az ad sp create-for-rbac `
    --name $ServicePrincipalName `
    --role contributor `
    --scopes "/subscriptions/$SubscriptionId" `
    --years 1 `
    --output json

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create service principal. Check your permissions."
    exit 1
}

# Extract credentials
$SpData = $SpOutput | ConvertFrom-Json
$ClientId = $SpData.clientId
$ClientSecret = $SpData.clientSecret
$TenantId = $SpData.tenantId

Write-Success "Service Principal created successfully!"
Write-Status "App ID: $ClientId"

# Create GitHub secret JSON
$SecretJson = @{
    clientId = $ClientId
    clientSecret = $ClientSecret
    subscriptionId = $SubscriptionId
    tenantId = $TenantId
} | ConvertTo-Json -Compress

# Add to GitHub if CLI is available
if (Get-Command gh -ErrorAction SilentlyContinue) {
    try {
        gh auth status 2>$null
        Write-Status "Adding secret to GitHub..."
        
        $SecretName = "AZURE_SERVICE_PRINCIPAL"
        if ($Environment -ne "dev") {
            $SecretName = "AZURE_SERVICE_PRINCIPAL_$($Environment.ToUpper())"
        }
        
        $SecretJson | gh secret set $SecretName
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✅ Secret '$SecretName' added to GitHub successfully!"
        } else {
            Write-Error "Failed to add secret to GitHub. Add manually:"
            Write-Host "Secret Name: $SecretName"
            Write-Host "Secret Value:"
            Write-Host $SecretJson
        }
    } catch {
        Write-Warning "GitHub CLI not authenticated"
        Write-Status "Add this secret manually to your GitHub repository:"
        Write-Host ""
        Write-Host "Secret Name: AZURE_SERVICE_PRINCIPAL"
        Write-Host "Secret Value:"
        Write-Host $SecretJson
    }
} else {
    Write-Warning "GitHub CLI not available"
    Write-Status "Add this secret manually to your GitHub repository:"
    Write-Host ""
    Write-Host "Secret Name: AZURE_SERVICE_PRINCIPAL"
    Write-Host "Secret Value:"
    Write-Host $SecretJson
}

Write-Success "✅ Setup complete!"
