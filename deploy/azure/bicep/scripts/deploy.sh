#!/bin/bash

# Deploy Sportiverse Infrastructure using Bicep
# This script deploys the Sportiverse web application infrastructure to Azure
# 
# Make this script executable: chmod +x deploy.sh
# Usage: ./deploy.sh -l <location> -p <paypal-client-id> -s <paypal-app-secret> -u <paypal-api-url> -j <jwt-secret>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT_NAME="dev"
APP_NAME="sportiverse"
APP_SERVICE_PLAN_SKU="B1"
TEMPLATE_FILE="main.bicep"
PARAMETERS_FILE="environments/dev.parameters.json"
WHAT_IF=false

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print usage
print_usage() {
    echo "Usage: $0 -l <location> [options]"
    echo ""
    echo "Required arguments:"
    echo "  -l, --location          Azure region (e.g., eastus, westeurope)"
    echo "  -p, --paypal-client-id  PayPal Client ID"
    echo "  -s, --paypal-app-secret PayPal App Secret"
    echo "  -u, --paypal-api-url    PayPal API URL (default: sandbox)"
    echo "  -j, --jwt-secret        JWT Secret for authentication"
    echo ""
    echo "Optional arguments:"
    echo "  -g, --resource-group    Azure resource group name (auto-generated if not provided)"
    echo "  -e, --environment       Environment name (default: dev)"
    echo "  -a, --app-name          Application name (default: sportiverse)"
    echo "  -k, --sku               App Service Plan SKU (default: B1)"
    echo "  -t, --template          Template file (default: main.bicep)"
    echo "  -f, --parameters        Parameters file (default: main.parameters.json)"
    echo "  -w, --what-if           Run what-if analysis instead of deployment"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -l eastus -p 'your-paypal-client-id' -s 'your-paypal-app-secret' -j 'your-jwt-secret'"
    echo "  $0 -g myResourceGroup -l eastus -p 'your-paypal-client-id' -s 'your-paypal-app-secret' -u 'https://api-m.paypal.com' -j 'your-jwt-secret'"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT_NAME="$2"
            shift 2
            ;;
        -a|--app-name)
            APP_NAME="$2"
            shift 2
            ;;
        -s|--sku)
            APP_SERVICE_PLAN_SKU="$2"
            shift 2
            ;;
        -p|--paypal-client-id)
            PAYPAL_CLIENT_ID="$2"
            shift 2
            ;;
        -s|--paypal-app-secret)
            PAYPAL_APP_SECRET="$2"
            shift 2
            ;;
        -u|--paypal-api-url)
            PAYPAL_API_URL="$2"
            shift 2
            ;;
        -j|--jwt-secret)
            JWT_SECRET="$2"
            shift 2
            ;;
        -k|--sku)
            APP_SERVICE_PLAN_SKU="$2"
            shift 2
            ;;
        -t|--template)
            TEMPLATE_FILE="$2"
            shift 2
            ;;
        -f|--parameters)
            PARAMETERS_FILE="$2"
            shift 2
            ;;
        -w|--what-if)
            WHAT_IF=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            print_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$LOCATION" ]]; then
    print_message $RED "❌ Error: Location is required"
    print_usage
    exit 1
fi

if [[ -z "$PAYPAL_CLIENT_ID" ]]; then
    print_message $RED "❌ Error: PayPal Client ID is required"
    print_usage
    exit 1
fi

if [[ -z "$PAYPAL_APP_SECRET" ]]; then
    print_message $RED "❌ Error: PayPal App Secret is required"
    print_usage
    exit 1
fi

if [[ -z "$JWT_SECRET" ]]; then
    print_message $RED "❌ Error: JWT Secret is required"
    print_usage
    exit 1
fi

# Set resource group name if not provided
if [[ -z "$RESOURCE_GROUP" ]]; then
    RESOURCE_GROUP="$APP_NAME-rg-$ENVIRONMENT_NAME"
    print_message $YELLOW "Resource Group: $RESOURCE_GROUP (auto-generated)"
else
    print_message $YELLOW "Resource Group: $RESOURCE_GROUP"
fi

# Set PayPal API URL default if not provided
if [[ -z "$PAYPAL_API_URL" ]]; then
    PAYPAL_API_URL="https://api-m.sandbox.paypal.com"
    print_message $YELLOW "PayPal API URL: $PAYPAL_API_URL (default: sandbox)"
else
    print_message $YELLOW "PayPal API URL: $PAYPAL_API_URL"
fi

print_message $GREEN "🚀 Starting Sportiverse Infrastructure Deployment"
print_message $YELLOW "Environment: $ENVIRONMENT_NAME"
print_message $YELLOW "Location: $LOCATION"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_message $RED "❌ Azure CLI is not installed"
    exit 1
fi

# Check Azure CLI version
AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
print_message $GREEN "✅ Azure CLI version: $AZ_VERSION"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    print_message $RED "❌ Not logged in to Azure. Please run 'az login'"
    exit 1
fi

ACCOUNT_INFO=$(az account show --query '{name:name, id:id, user:user.name}' -o json)
ACCOUNT_NAME=$(echo $ACCOUNT_INFO | jq.exe -r '.name')
ACCOUNT_ID=$(echo $ACCOUNT_INFO | jq.exe -r '.id')
USER_NAME=$(echo $ACCOUNT_INFO | jq.exe -r '.user')

print_message $GREEN "✅ Logged in as: $USER_NAME"
print_message $GREEN "✅ Subscription: $ACCOUNT_NAME ($ACCOUNT_ID)"

# Create resource group if it doesn't exist
print_message $BLUE "📦 Resource group will be created as part of the deployment..."

# Generate deployment name
DEPLOYMENT_NAME="sportiverse-deployment-$(date +%Y%m%d-%H%M%S)"

# Build deployment parameters
DEPLOYMENT_PARAMS=$(jq.exe -n \
    --arg environmentName "$ENVIRONMENT_NAME" \
    --arg appName "$APP_NAME" \
    --arg location "$LOCATION" \
    --arg resourceGroupName "$RESOURCE_GROUP" \
    --arg appServicePlanSku "$APP_SERVICE_PLAN_SKU" \
    --arg paypalClientId "$PAYPAL_CLIENT_ID" \
    --arg paypalAppSecret "$PAYPAL_APP_SECRET" \
    --arg paypalApiUrl "$PAYPAL_API_URL" \
    --arg jwtSecret "$JWT_SECRET" \
    '{
        environmentName: $environmentName,
        appName: $appName,
        location: $location,
        resourceGroupName: $resourceGroupName,
        appServicePlanSku: $appServicePlanSku,
        paypalClientId: $paypalClientId,
        paypalAppSecret: $paypalAppSecret,
        paypalApiUrl: $paypalApiUrl,
        jwtSecret: $jwtSecret
    }')

# Build Azure CLI command
AZ_COMMAND="az deployment sub create --location $LOCATION --name $DEPLOYMENT_NAME --template-file $TEMPLATE_FILE --parameters '$DEPLOYMENT_PARAMS' --output table"

if [[ "$WHAT_IF" == true ]]; then
    AZ_COMMAND="$AZ_COMMAND --what-if"
    print_message $BLUE "🔍 Running what-if analysis..."
else
    print_message $BLUE "🚀 Deploying infrastructure..."
fi

# Execute deployment
print_message $WHITE "Executing: $AZ_COMMAND"
eval $AZ_COMMAND

if [[ $? -ne 0 ]]; then
    print_message $RED "❌ Deployment failed"
    exit 1
fi

if [[ "$WHAT_IF" != true ]]; then
    print_message $GREEN "✅ Deployment completed successfully!"
    
    # Get deployment outputs
    print_message $BLUE "📋 Getting deployment outputs..."
    OUTPUTS=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query properties.outputs --output json)
    
    if [[ -n "$OUTPUTS" && "$OUTPUTS" != "null" ]]; then
        WEB_APP_URL=$(echo $OUTPUTS | jq.exe -r '.webAppUrl.value // empty')
        API_URL=$(echo $OUTPUTS | jq.exe -r '.apiUrl.value // empty')
        COSMOS_DB_ACCOUNT=$(echo $OUTPUTS | jq.exe -r '.cosmosDbAccountName.value // empty')
        RESOURCE_GROUP_NAME=$(echo $OUTPUTS | jq.exe -r '.resourceGroupName.value // empty')
        
        echo ""
        print_message $GREEN "🎯 Deployment Outputs:"
        [[ -n "$WEB_APP_URL" ]] && print_message $CYAN "Web App URL: $WEB_APP_URL"
        [[ -n "$API_URL" ]] && print_message $CYAN "API URL: $API_URL"
        [[ -n "$COSMOS_DB_ACCOUNT" ]] && print_message $CYAN "Cosmos DB Account: $COSMOS_DB_ACCOUNT"
        [[ -n "$RESOURCE_GROUP_NAME" ]] && print_message $CYAN "Resource Group: $RESOURCE_GROUP_NAME"
        
        echo ""
        print_message $YELLOW "📝 Next Steps:"
        print_message $WHITE "1. Deploy your application code to the App Services"
        print_message $WHITE "2. Configure custom domains if needed"
        print_message $WHITE "3. Set up monitoring and alerts"
        print_message $WHITE "4. Configure backup policies"
    fi
fi

echo ""
print_message $GREEN "🎉 Script completed!"
