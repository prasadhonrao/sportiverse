#!/bin/bash

# Setup Development GitHub Secrets for Sportiverse
# Usage: ./setup-dev-secrets.sh [--generate-defaults]

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

# Parse arguments
GENERATE_DEFAULTS=false
JWT_SECRET=""
PAYPAL_CLIENT_ID=""
PAYPAL_APP_SECRET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --generate-defaults)
            GENERATE_DEFAULTS=true
            shift
            ;;
        --jwt-secret)
            JWT_SECRET="$2"
            shift 2
            ;;
        --paypal-client-id)
            PAYPAL_CLIENT_ID="$2"
            shift 2
            ;;
        --paypal-app-secret)
            PAYPAL_APP_SECRET="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --generate-defaults     Generate default/example values"
            echo "  --jwt-secret VALUE      Specify JWT secret"
            echo "  --paypal-client-id ID   Specify PayPal client ID"
            echo "  --paypal-app-secret SECRET  Specify PayPal app secret"
            echo "  -h, --help             Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_status "Setting up Development GitHub Secrets for Sportiverse"

# Check if GitHub CLI is available
if ! command -v gh &>/dev/null; then
    print_error "GitHub CLI (gh) not found. Please install it first:"
    echo "   macOS: brew install gh"
    echo "   Linux: See https://cli.github.com/"
    echo "   Windows: winget install GitHub.cli"
    exit 1
fi

# Check GitHub authentication
if ! gh auth status &>/dev/null; then
    print_error "GitHub CLI not authenticated. Please run: gh auth login"
    exit 1
fi

print_success "GitHub CLI authenticated"

# Verify we're in the correct repository
REPO_INFO=$(gh repo view --json name,owner 2>/dev/null)
REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')
REPO_OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')

if [ "$REPO_NAME" != "sportiverse" ]; then
    print_warning "Not in sportiverse repository. Current repo: $REPO_OWNER/$REPO_NAME"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Exiting..."
        exit 0
    fi
else
    print_success "Verified repository: $REPO_OWNER/$REPO_NAME"
fi

# Generate default values if requested or if values not provided
if [ "$GENERATE_DEFAULTS" = true ] || [ -z "$JWT_SECRET" ] && [ -z "$PAYPAL_CLIENT_ID" ] && [ -z "$PAYPAL_APP_SECRET" ]; then
    print_status "Generating default development values..."
    
    # Generate JWT secret
    if [ -z "$JWT_SECRET" ]; then
        if command -v openssl &>/dev/null; then
            JWT_SECRET=$(openssl rand -base64 32)
        else
            # Fallback if openssl not available
            JWT_SECRET="dev-jwt-secret-$(date +%s)-$(shuf -i 1000-9999 -n 1)"
        fi
        print_status "Generated JWT secret: ${JWT_SECRET:0:8}..."
    fi
    
    # Set default PayPal sandbox values
    if [ -z "$PAYPAL_CLIENT_ID" ]; then
        PAYPAL_CLIENT_ID="sb-dev-$(shuf -i 100000-999999 -n 1)@business.example.com"
        print_status "Generated PayPal Client ID: $PAYPAL_CLIENT_ID"
    fi
    
    if [ -z "$PAYPAL_APP_SECRET" ]; then
        PAYPAL_APP_SECRET="EH$(shuf -i 100000-999999 -n 1)-DEV-SANDBOX-SECRET-$(shuf -i 1000-9999 -n 1)"
        print_status "Generated PayPal App Secret: ${PAYPAL_APP_SECRET:0:12}..."
    fi
    
    print_warning "Generated default/example values for development."
    print_warning "For production use, replace PayPal values with real sandbox credentials from:"
    print_warning "https://developer.paypal.com/developer/applications/"
fi

# Prompt for values if not provided and not generating defaults
if [ -z "$JWT_SECRET" ]; then
    read -p "Enter JWT Secret for development (or press Enter to generate): " JWT_SECRET
    if [ -z "$JWT_SECRET" ]; then
        if command -v openssl &>/dev/null; then
            JWT_SECRET=$(openssl rand -base64 32)
        else
            JWT_SECRET="dev-jwt-secret-$(date +%s)-$(shuf -i 1000-9999 -n 1)"
        fi
        print_status "Generated JWT secret"
    fi
fi

if [ -z "$PAYPAL_CLIENT_ID" ]; then
    read -p "Enter PayPal Client ID for development (sandbox): " PAYPAL_CLIENT_ID
    if [ -z "$PAYPAL_CLIENT_ID" ]; then
        print_error "PayPal Client ID is required"
        exit 1
    fi
fi

if [ -z "$PAYPAL_APP_SECRET" ]; then
    read -p "Enter PayPal App Secret for development (sandbox): " PAYPAL_APP_SECRET
    if [ -z "$PAYPAL_APP_SECRET" ]; then
        print_error "PayPal App Secret is required"
        exit 1
    fi
fi

# Set the secrets
print_status "Setting GitHub repository secrets..."

# Set DEV_JWT_SECRET
print_status "Setting DEV_JWT_SECRET..."
if echo "$JWT_SECRET" | gh secret set DEV_JWT_SECRET; then
    print_success "✅ DEV_JWT_SECRET set successfully"
else
    print_error "Failed to set DEV_JWT_SECRET"
    exit 1
fi

# Set DEV_PAYPAL_CLIENT_ID
print_status "Setting DEV_PAYPAL_CLIENT_ID..."
if echo "$PAYPAL_CLIENT_ID" | gh secret set DEV_PAYPAL_CLIENT_ID; then
    print_success "✅ DEV_PAYPAL_CLIENT_ID set successfully"
else
    print_error "Failed to set DEV_PAYPAL_CLIENT_ID"
    exit 1
fi

# Set DEV_PAYPAL_APP_SECRET
print_status "Setting DEV_PAYPAL_APP_SECRET..."
if echo "$PAYPAL_APP_SECRET" | gh secret set DEV_PAYPAL_APP_SECRET; then
    print_success "✅ DEV_PAYPAL_APP_SECRET set successfully"
else
    print_error "Failed to set DEV_PAYPAL_APP_SECRET"
    exit 1
fi

print_success "🎉 All development secrets set successfully!"

# Verify secrets are set
print_status "Verifying secrets are configured..."
SECRETS_LIST=$(gh secret list --json name 2>/dev/null || echo "[]")
REQUIRED_SECRETS=("DEV_JWT_SECRET" "DEV_PAYPAL_CLIENT_ID" "DEV_PAYPAL_APP_SECRET" "AZURE_SERVICE_PRINCIPAL")

print_status "📋 Repository secrets status:"
for secret in "${REQUIRED_SECRETS[@]}"; do
    if echo "$SECRETS_LIST" | jq -e ".[] | select(.name == \"$secret\")" >/dev/null 2>&1; then
        print_success "   ✅ $secret"
    else
        print_warning "   ❓ $secret (not found)"
    fi
done

print_success "✅ Development secrets setup complete!"
echo ""
print_status "📋 Next steps:"
print_status "   1. Test infrastructure workflow: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/infra-azure-app-service.yml"
print_status "   2. Run workflow with 'dev' environment to test secret seeding"
print_status "   3. Verify dev Key Vault gets seeded with these secrets"
echo ""
print_status "🔐 Security notes:"
print_status "   - These secrets will be automatically seeded to dev Key Vault"
print_status "   - Production secrets are configured manually (not stored in GitHub)"
print_status "   - PayPal values should be sandbox credentials for development"
