#!/bin/bash

# Simple Azure Service Principal Setup for GitHub Actions
# Usage: ./simple-sp-setup.sh <subscription-id> <environment>

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check arguments
if [ $# -ne 2 ]; then
    print_error "Usage: $0 <subscription-id> <environment>"
    print_error "Example: $0 'ecae752b-db4e-4d9d-8585-278eecd89177' 'dev'"
    exit 1
fi

SUBSCRIPTION_ID="$1"
ENVIRONMENT="$2"
SERVICE_PRINCIPAL_NAME="sportiverse-cicd-${ENVIRONMENT}"

print_status "Setting up Service Principal: $SERVICE_PRINCIPAL_NAME"
print_status "Subscription: $SUBSCRIPTION_ID"

# Login check
if ! az account show &>/dev/null; then
    print_error "Not logged into Azure CLI. Please run: az login"
    exit 1
fi

# Set subscription
print_status "Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Verify subscription is set
CURRENT_SUB=$(az account show --query "id" -o tsv 2>/dev/null)
if [ "$CURRENT_SUB" != "$SUBSCRIPTION_ID" ]; then
    print_error "Failed to set subscription. Check if subscription ID is correct and you have access."
    print_error "Available subscriptions:"
    az account list --query "[].{Name:name, SubscriptionId:id}" -o table
    exit 1
fi

print_success "Subscription set: $CURRENT_SUB"

# Delete existing service principal if it exists
print_status "Checking for existing service principal..."
EXISTING_SP=$(az ad sp list --display-name "$SERVICE_PRINCIPAL_NAME" --query "[0].appId" -o tsv 2>/dev/null)
if [ -n "$EXISTING_SP" ] && [ "$EXISTING_SP" != "null" ]; then
    print_warning "Deleting existing service principal: $EXISTING_SP"
    az ad sp delete --id "$EXISTING_SP"
fi

# Create service principal using the same command that worked for you
print_status "Creating service principal with subscription-level contributor access..."
SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SERVICE_PRINCIPAL_NAME" \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID \
    --years 1 \
    --output json)

if [ $? -ne 0 ]; then
    print_error "Failed to create service principal. Check your permissions."
    exit 1
fi

# Extract credentials
CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.clientId')
CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.clientSecret')
TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenantId')

print_success "Service Principal created successfully!"
print_status "App ID: $CLIENT_ID"

# Create GitHub secret JSON
SECRET_JSON=$(cat <<EOF
{
  "clientId": "$CLIENT_ID",
  "clientSecret": "$CLIENT_SECRET",
  "subscriptionId": "$SUBSCRIPTION_ID",
  "tenantId": "$TENANT_ID"
}
EOF
)

# Add to GitHub if CLI is available
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    print_status "Adding secret to GitHub..."
    
    SECRET_NAME="AZURE_SERVICE_PRINCIPAL"
    if [ "$ENVIRONMENT" != "dev" ]; then
        SECRET_NAME="AZURE_SERVICE_PRINCIPAL_$(echo $ENVIRONMENT | tr '[:lower:]' '[:upper:]')"
    fi
    
    if echo "$SECRET_JSON" | gh secret set "$SECRET_NAME"; then
        print_success "✅ Secret '$SECRET_NAME' added to GitHub successfully!"
    else
        print_error "Failed to add secret to GitHub. Add manually:"
        echo "Secret Name: $SECRET_NAME"
        echo "Secret Value:"
        echo "$SECRET_JSON"
    fi
else
    print_warning "GitHub CLI not available or not authenticated"
    print_status "Add this secret manually to your GitHub repository:"
    echo ""
    echo "Secret Name: AZURE_SERVICE_PRINCIPAL"
    echo "Secret Value:"
    echo "$SECRET_JSON"
fi

print_success "✅ Setup complete!"
