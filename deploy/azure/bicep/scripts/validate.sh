#!/bin/bash

# Validation script for Sportiverse Bicep templates
# This script validates the Bicep templates before deployment
#
# Make this script executable: chmod +x validate.sh
# Usage: ./validate.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_message $GREEN "🔍 Validating Sportiverse Bicep Templates"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    print_message $RED "❌ Azure CLI is not installed"
    exit 1
fi

# Check if Bicep CLI is available
if ! az bicep version &> /dev/null; then
    print_message $YELLOW "⚠️  Bicep CLI not found, installing..."
    az bicep install
fi

print_message $GREEN "✅ Azure CLI and Bicep CLI are available"

# Validate main template
print_message $BLUE "📋 Validating main.bicep template..."
if az bicep build --file main.bicep --stdout > /dev/null; then
    print_message $GREEN "✅ main.bicep is valid"
else
    print_message $RED "❌ main.bicep has validation errors"
    exit 1
fi

# Validate resourceGroup module
print_message $BLUE "📋 Validating modules/resource-group/resourceGroup.bicep..."
if az bicep build --file modules/resource-group/resourceGroup.bicep --stdout > /dev/null; then
    print_message $GREEN "✅ modules/resource-group/resourceGroup.bicep is valid"
else
    print_message $RED "❌ modules/resource-group/resourceGroup.bicep has validation errors"
    exit 1
fi

# Validate each module
modules=("app-service/appServicePlan" "database/cosmosDb" "app-service/webApi" "app-service/webApp")

for module in "${modules[@]}"; do
    print_message $BLUE "📋 Validating modules/${module}.bicep..."
    if az bicep build --file "modules/${module}.bicep" --stdout > /dev/null; then
        print_message $GREEN "✅ modules/${module}.bicep is valid"
    else
        print_message $RED "❌ modules/${module}.bicep has validation errors"
        exit 1
    fi
done

# Check parameter files
if [[ -f "environments/dev.parameters.json" ]]; then
    print_message $BLUE "📋 Validating environments/dev.parameters.json..."
    if node -e "try { JSON.parse(require('fs').readFileSync('environments/dev.parameters.json', 'utf8')); console.log('Valid JSON'); } catch(e) { console.error('Invalid JSON:', e.message); process.exit(1); }" > /dev/null 2>&1; then
        print_message $GREEN "✅ environments/dev.parameters.json is valid JSON"
    else
        print_message $RED "❌ environments/dev.parameters.json is not valid JSON"
        exit 1
    fi
fi

if [[ -f "main.bicepparam" ]]; then
    print_message $BLUE "📋 Validating main.bicepparam..."
    # Note: There's no direct validation for .bicepparam files yet
    print_message $YELLOW "⚠️  .bicepparam validation not available, skipping"
fi

print_message $GREEN "🎉 All templates are valid!"

# Check for best practices
print_message $BLUE "📋 Checking best practices..."

# Check if all resources have tags
if grep -q "tags: tags" main.bicep && find modules/ -name "*.bicep" -exec grep -q "tags: tags" {} \;; then
    print_message $GREEN "✅ Resources are properly tagged"
else
    print_message $YELLOW "⚠️  Some resources might not be properly tagged"
fi

# Check for secure parameters
if grep -q "@secure()" main.bicep; then
    print_message $GREEN "✅ Secure parameters are properly marked"
else
    print_message $YELLOW "⚠️  No secure parameters found (this might be okay)"
fi

# Check for parameter descriptions
if grep -q "@description(" main.bicep modules/*.bicep; then
    print_message $GREEN "✅ Parameters have descriptions"
else
    print_message $YELLOW "⚠️  Some parameters might be missing descriptions"
fi

print_message $GREEN "🎉 Validation completed!"
