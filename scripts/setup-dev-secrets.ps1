# Setup Development GitHub Secrets for Sportiverse
# Usage: .\setup-dev-secrets.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$JwtSecret = $null,
    
    [Parameter(Mandatory=$false)]
    [string]$PaypalClientId = $null,
    
    [Parameter(Mandatory=$false)]
    [string]$PaypalAppSecret = $null,
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateDefaults = $false
)

# Function to write colored output
function Write-Status($message) { Write-Host "[INFO] $message" -ForegroundColor Blue }
function Write-Success($message) { Write-Host "[SUCCESS] $message" -ForegroundColor Green }
function Write-Warning($message) { Write-Host "[WARNING] $message" -ForegroundColor Yellow }
function Write-Error($message) { Write-Host "[ERROR] $message" -ForegroundColor Red }

Write-Status "Setting up Development GitHub Secrets for Sportiverse"

# Check if GitHub CLI is available
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) not found. Please install it first:"
    Write-Host "   Windows: winget install GitHub.cli"
    Write-Host "   See: https://cli.github.com/"
    exit 1
}

# Check GitHub authentication
try {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI not authenticated. Please run: gh auth login"
        exit 1
    }
    Write-Success "GitHub CLI authenticated"
} catch {
    Write-Error "GitHub CLI authentication failed. Please run: gh auth login"
    exit 1
}

# Verify we're in the correct repository
try {
    $repoInfo = gh repo view --json name,owner | ConvertFrom-Json
    if ($repoInfo.name -ne "sportiverse") {
        Write-Warning "Not in sportiverse repository. Current repo: $($repoInfo.owner.login)/$($repoInfo.name)"
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Status "Exiting..."
            exit 0
        }
    } else {
        Write-Success "Verified repository: $($repoInfo.owner.login)/$($repoInfo.name)"
    }
} catch {
    Write-Error "Failed to verify repository. Are you in the correct directory?"
    exit 1
}

# Generate default values if requested or if values not provided
if ($GenerateDefaults -or (-not $JwtSecret -and -not $PaypalClientId -and -not $PaypalAppSecret)) {
    Write-Status "Generating default development values..."
    
    # Generate JWT secret
    if (-not $JwtSecret) {
        # Generate a secure random string for JWT
        $bytes = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
        $JwtSecret = [Convert]::ToBase64String($bytes)
        Write-Status "Generated JWT secret: $($JwtSecret.Substring(0, 8))..."
    }
    
    # Set default PayPal sandbox values (these are example sandbox values)
    if (-not $PaypalClientId) {
        $PaypalClientId = "sb-dev-$(Get-Random -Minimum 100000 -Maximum 999999)@business.example.com"
        Write-Status "Generated PayPal Client ID: $PaypalClientId"
    }
    
    if (-not $PaypalAppSecret) {
        $PaypalAppSecret = "EH$(Get-Random -Minimum 100000 -Maximum 999999)-DEV-SANDBOX-SECRET-$(Get-Random -Minimum 1000 -Maximum 9999)"
        Write-Status "Generated PayPal App Secret: $($PaypalAppSecret.Substring(0, 12))..."
    }
    
    Write-Warning "Generated default/example values for development."
    Write-Warning "For production use, replace PayPal values with real sandbox credentials from:"
    Write-Warning "https://developer.paypal.com/developer/applications/"
}

# Prompt for values if not provided and not generating defaults
if (-not $JwtSecret) {
    $JwtSecret = Read-Host "Enter JWT Secret for development (or press Enter to generate)"
    if (-not $JwtSecret) {
        $bytes = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
        $JwtSecret = [Convert]::ToBase64String($bytes)
        Write-Status "Generated JWT secret"
    }
}

if (-not $PaypalClientId) {
    $PaypalClientId = Read-Host "Enter PayPal Client ID for development (sandbox)"
    if (-not $PaypalClientId) {
        Write-Error "PayPal Client ID is required"
        exit 1
    }
}

if (-not $PaypalAppSecret) {
    $PaypalAppSecret = Read-Host "Enter PayPal App Secret for development (sandbox)"
    if (-not $PaypalAppSecret) {
        Write-Error "PayPal App Secret is required"
        exit 1
    }
}

# Set the secrets
Write-Status "Setting GitHub repository secrets..."

try {
    # Set DEV_JWT_SECRET
    Write-Status "Setting DEV_JWT_SECRET..."
    $JwtSecret | gh secret set DEV_JWT_SECRET
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ DEV_JWT_SECRET set successfully"
    } else {
        Write-Error "Failed to set DEV_JWT_SECRET"
        exit 1
    }

    # Set DEV_PAYPAL_CLIENT_ID
    Write-Status "Setting DEV_PAYPAL_CLIENT_ID..."
    $PaypalClientId | gh secret set DEV_PAYPAL_CLIENT_ID
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ DEV_PAYPAL_CLIENT_ID set successfully"
    } else {
        Write-Error "Failed to set DEV_PAYPAL_CLIENT_ID"
        exit 1
    }

    # Set DEV_PAYPAL_APP_SECRET
    Write-Status "Setting DEV_PAYPAL_APP_SECRET..."
    $PaypalAppSecret | gh secret set DEV_PAYPAL_APP_SECRET
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ DEV_PAYPAL_APP_SECRET set successfully"
    } else {
        Write-Error "Failed to set DEV_PAYPAL_APP_SECRET"
        exit 1
    }

    Write-Success "🎉 All development secrets set successfully!"
    
} catch {
    Write-Error "Failed to set GitHub secrets: $_"
    exit 1
}

# Verify secrets are set
Write-Status "Verifying secrets are configured..."
try {
    $secrets = gh secret list --json name | ConvertFrom-Json
    $requiredSecrets = @("DEV_JWT_SECRET", "DEV_PAYPAL_CLIENT_ID", "DEV_PAYPAL_APP_SECRET", "AZURE_SERVICE_PRINCIPAL")
    
    Write-Status "📋 Repository secrets status:"
    foreach ($required in $requiredSecrets) {
        $found = $secrets | Where-Object { $_.name -eq $required }
        if ($found) {
            Write-Success "   ✅ $required"
        } else {
            Write-Warning "   ❓ $required (not found)"
        }
    }
    
} catch {
    Write-Warning "Could not verify secrets (this is normal - secrets are encrypted)"
}

Write-Success "✅ Development secrets setup complete!"
Write-Status ""
Write-Status "📋 Next steps:"
Write-Status "   1. Test infrastructure workflow: https://github.com/$($repoInfo.owner.login)/$($repoInfo.name)/actions/workflows/infra-azure-app-service.yml"
Write-Status "   2. Run workflow with 'dev' environment to test secret seeding"
Write-Status "   3. Verify dev Key Vault gets seeded with these secrets"
Write-Status ""
Write-Status "🔐 Security notes:"
Write-Status "   - These secrets will be automatically seeded to dev Key Vault"
Write-Status "   - Production secrets are configured manually (not stored in GitHub)"
Write-Status "   - PayPal values should be sandbox credentials for development"
