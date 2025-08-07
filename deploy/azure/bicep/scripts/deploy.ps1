# Deploy Sportiverse Infrastructure using Bicep
# This script deploys the Sportiverse web application infrastructure to Azure

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName = "dev",
    
    [Parameter(Mandatory=$false)]
    [string]$AppName = "sportiverse",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlanSku = "B1",
    
    [Parameter(Mandatory=$true)]
    [string]$PayPalClientId,
    
    [Parameter(Mandatory=$true)]
    [string]$PayPalAppSecret,
    
    [Parameter(Mandatory=$false)]
    [string]$PayPalApiUrl = "https://api-m.sandbox.paypal.com",
    
    [Parameter(Mandatory=$true)]
    [string]$JwtSecret,
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateFile = "main.bicep",
    
    [Parameter(Mandatory=$false)]
    [string]$ParametersFile = "main.parameters.json",
    
    [Parameter(Mandatory=$false)]
    [switch]$WhatIf
)

# Set error action preference
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Sportiverse Infrastructure Deployment" -ForegroundColor Green
Write-Host "Environment: $EnvironmentName" -ForegroundColor Yellow
Write-Host "Location: $Location" -ForegroundColor Yellow

# Set resource group name if not provided
if ([string]::IsNullOrEmpty($ResourceGroupName)) {
    $ResourceGroupName = "$AppName-rg-$EnvironmentName"
    Write-Host "Resource Group: $ResourceGroupName (auto-generated)" -ForegroundColor Yellow
} else {
    Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
}

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host "❌ Azure CLI is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if logged in to Azure
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
    Write-Host "✅ Subscription: $($account.name) ($($account.id))" -ForegroundColor Green
}
catch {
    Write-Host "❌ Not logged in to Azure. Please run 'az login'" -ForegroundColor Red
    exit 1
}

# Create resource group if it doesn't exist
Write-Host "📦 Resource group will be created as part of the deployment..." -ForegroundColor Blue

# Build deployment parameters
$deploymentParams = @{
    'environmentName' = $EnvironmentName
    'appName' = $AppName
    'location' = $Location
    'resourceGroupName' = $ResourceGroupName
    'appServicePlanSku' = $AppServicePlanSku
    'paypalClientId' = $PayPalClientId
    'paypalAppSecret' = $PayPalAppSecret
    'paypalApiUrl' = $PayPalApiUrl
    'jwtSecret' = $JwtSecret
}

# Convert parameters to JSON
$paramsJson = ($deploymentParams | ConvertTo-Json -Compress).Replace('"', '\"')

# Generate deployment name
$deploymentName = "sportiverse-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Build Azure CLI command
$azCommand = @(
    'az', 'deployment', 'sub', 'create'
    '--location', $Location
    '--name', $deploymentName
    '--template-file', $TemplateFile
    '--parameters', $paramsJson
    '--output', 'table'
)

if ($WhatIf) {
    $azCommand += '--what-if'
    Write-Host "🔍 Running what-if analysis..." -ForegroundColor Blue
} else {
    Write-Host "🚀 Deploying infrastructure..." -ForegroundColor Blue
}

# Execute deployment
Write-Host "Executing: $($azCommand -join ' ')" -ForegroundColor Gray
& $azCommand[0] $azCommand[1..($azCommand.Length-1)]

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Deployment failed" -ForegroundColor Red
    exit 1
}

if (-not $WhatIf) {
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    
    # Get deployment outputs
    Write-Host "📋 Getting deployment outputs..." -ForegroundColor Blue
    $outputs = az deployment sub show --name $deploymentName --query properties.outputs --output json | ConvertFrom-Json
    
    if ($outputs) {
        Write-Host "`n🎯 Deployment Outputs:" -ForegroundColor Green
        Write-Host "Web App URL: $($outputs.webAppUrl.value)" -ForegroundColor Cyan
        Write-Host "API URL: $($outputs.apiUrl.value)" -ForegroundColor Cyan
        Write-Host "Cosmos DB Account: $($outputs.cosmosDbAccountName.value)" -ForegroundColor Cyan
        Write-Host "Resource Group: $($outputs.resourceGroupName.value)" -ForegroundColor Cyan
        
        Write-Host "`n📝 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Deploy your application code to the App Services" -ForegroundColor White
        Write-Host "2. Configure custom domains if needed" -ForegroundColor White
        Write-Host "3. Set up monitoring and alerts" -ForegroundColor White
        Write-Host "4. Configure backup policies" -ForegroundColor White
    }
}

Write-Host "`n🎉 Script completed!" -ForegroundColor Green
