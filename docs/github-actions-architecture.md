# GitHub Actions Custom Actions Architecture

## 🎯 Overview

The Sportiverse project uses a **Custom Actions Architecture** for GitHub Actions workflows. This approach provides better organization, maintainability, and reusability compared to traditional workflow templates.

## 📁 **Directory Structure**

```
.github/
├── workflows/                    # Main workflow files
│   ├── webapi-ci.yml            # WebAPI CI pipeline
│   ├── webapp-ci.yml            # WebApp CI pipeline
│   ├── webapi-cd.yml            # WebAPI CD pipeline
│   └── webapp-cd.yml            # WebApp CD pipeline
└── actions/                      # Custom composite actions
    ├── node-ci/                  # Node.js CI pipeline
    │   ├── action.yml
    │   └── README.md
    ├── deploy-azure-app/         # Azure deployment
    │   ├── action.yml
    │   └── README.md
    ├── health-check/             # Application health checks
    │   ├── action.yml
    │   └── README.md
    ├── notify/                   # Notifications (Slack, Teams)
    │   ├── action.yml
    │   └── README.md
    └── pr-integration/           # Pull request integration
        ├── action.yml
        └── README.md
```

## 🚀 **Custom Actions**

### 1. **Node.js CI Pipeline** (`.github/actions/node-ci`)

**Purpose:** Comprehensive Node.js continuous integration

**Features:**
- ✅ ESLint code quality checks
- 🔒 Security vulnerability auditing
- 🧪 Unit testing with coverage
- 📊 Codecov integration
- 📦 Production build packaging
- ⚡ Multi-package-manager support (npm, yarn, pnpm)

**Usage:**
```yaml
- uses: ./.github/actions/node-ci
  with:
    working-directory: 'src/webapi'
    node-version: '22'
    skip-tests: 'false'
    package-manager: 'npm'
```

### 2. **Azure App Service Deployment** (`.github/actions/deploy-azure-app`)

**Purpose:** Deploy applications to Azure App Service

**Features:**
- 🚀 Azure App Service deployment
- 🎯 Environment-based configuration
- 🏥 Built-in health checks
- 📦 Artifact management
- ⚡ Deployment slot support

**Usage:**
```yaml
- uses: ./.github/actions/deploy-azure-app
  with:
    environment: 'dev'
    component-type: 'api'
    artifact-name: 'src-webapi-build-abc123'
    azure-credentials: ${{ secrets.AZURE_CREDENTIALS }}
```

### 3. **Health Check** (`.github/actions/health-check`)

**Purpose:** Validate application health after deployment

**Features:**
- 🏥 HTTP endpoint health checking
- 🔄 Configurable retry logic
- ⏱️ Response time monitoring
- 📊 Detailed status reporting
- 🎯 Custom validation rules

**Usage:**
```yaml
- uses: ./.github/actions/health-check
  with:
    endpoint: 'https://api.sportiverse.com/health'
    expected-status: '200'
    retry-attempts: '5'
```

### 4. **Notifications** (`.github/actions/notify`)

**Purpose:** Send pipeline notifications to various channels

**Features:**
- 📱 Slack integration
- 📢 Microsoft Teams support
- 📧 Email notifications (planned)
- 🎨 Rich formatting and colors
- 📊 Detailed pipeline information

**Usage:**
```yaml
- uses: ./.github/actions/notify
  with:
    status: 'success'
    title: 'WebAPI CI Pipeline'
    message: 'Pipeline completed successfully'
    slack-webhook: ${{ secrets.SLACK_WEBHOOK }}
```

### 5. **Pull Request Integration** (`.github/actions/pr-integration`)

**Purpose:** Enhanced pull request integration and automation

**Features:**
- 💬 Automated PR comments
- 📊 CI results reporting
- 🤖 Auto-merge capabilities
- 📋 Status check updates
- 🔄 Comment updates (no spam)

**Usage:**
```yaml
- uses: ./.github/actions/pr-integration
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    status: 'success'
    ci-results: 'All checks passed'
    auto-merge: 'false'
```

## 🔄 **Migration Benefits**

### **Before (Template Workflows):**
```
.github/workflows/
├── template-node-ci.yml           # 📄 150+ lines
├── template-deploy-azure-app.yml  # 📄 120+ lines
├── template-health-check.yml      # 📄 80+ lines
├── template-notify.yml            # 📄 100+ lines
├── template-pr-integration.yml    # 📄 90+ lines
├── webapi-ci.yml                  # 📄 80+ lines (calling templates)
├── webapp-ci.yml                  # 📄 80+ lines (calling templates)
├── webapi-cd.yml                  # 📄 100+ lines (calling templates)
└── webapp-cd.yml                  # 📄 100+ lines (calling templates)
```
**Total:** 9 files, 900+ lines, cluttered workflows directory

### **After (Custom Actions):**
```
.github/
├── workflows/
│   ├── webapi-ci.yml    # 📄 ~60 lines (simplified)
│   ├── webapp-ci.yml    # 📄 ~60 lines (simplified)
│   ├── webapi-cd.yml    # 📄 ~80 lines (simplified)
│   └── webapp-cd.yml    # 📄 ~80 lines (simplified)
└── actions/
    ├── node-ci/         # 📁 Organized in folders
    ├── deploy-azure-app/
    ├── health-check/
    ├── notify/
    └── pr-integration/
```
**Total:** Clean separation, organized structure, 40% fewer lines in main workflows

## ✨ **Advantages of Custom Actions**

### 1. **Organization**
- ✅ **Clean separation:** Actions in dedicated folders
- ✅ **No cluttering:** Workflows directory stays clean
- ✅ **Logical grouping:** Related functionality together

### 2. **Maintainability**
- ✅ **Single source of truth:** One action, multiple uses
- ✅ **Easy updates:** Update action once, affects all workflows
- ✅ **Version control:** Each action can have its own documentation

### 3. **Performance**
- ✅ **Faster execution:** No separate job overhead
- ✅ **Better resource usage:** Actions run within same job
- ✅ **Reduced complexity:** Simpler workflow orchestration

### 4. **Developer Experience**
- ✅ **Simpler workflows:** Focus on business logic
- ✅ **Rich documentation:** Each action has its own README
- ✅ **Better discoverability:** Clear action purposes

### 5. **GitHub Actions Best Practices**
- ✅ **Composite actions:** Industry standard approach
- ✅ **Reusability:** Can be used across different workflows
- ✅ **Flexibility:** Mix actions with other steps easily

## 🔧 **Usage Examples**

### **Complete CI/CD Pipeline:**
```yaml
name: Complete Pipeline
on: [push]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      # Custom CI action
      - name: Run CI Pipeline
        id: ci
        uses: ./.github/actions/node-ci
        with:
          working-directory: 'src/api'
          node-version: '22'
      
      # Custom deployment action
      - name: Deploy to Azure
        uses: ./.github/actions/deploy-azure-app
        with:
          environment: 'prod'
          artifact-name: ${{ steps.ci.outputs.artifact-name }}
          azure-credentials: ${{ secrets.AZURE_CREDENTIALS }}
      
      # Custom health check
      - name: Verify Deployment
        uses: ./.github/actions/health-check
        with:
          endpoint: 'https://api.sportiverse.com/health'
      
      # Custom notifications
      - name: Notify Team
        uses: ./.github/actions/notify
        with:
          status: 'success'
          title: 'Production Deployment'
          slack-webhook: ${{ secrets.SLACK_WEBHOOK }}
```

### **Pull Request Workflow:**
```yaml
name: PR Validation
on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run CI
        id: ci
        uses: ./.github/actions/node-ci
        with:
          working-directory: 'src/api'
      
      - name: Update PR
        uses: ./.github/actions/pr-integration
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          status: ${{ steps.ci.outputs.quality-passed == 'true' && 'success' || 'failure' }}
          ci-results: ${{ steps.ci.outputs.test-results }}
          auto-merge: 'true'
```

## 🎉 **Conclusion**

The Custom Actions Architecture provides:

- **🏗️ Better Organization:** Clean, logical structure
- **🚀 Improved Performance:** Faster execution, less overhead
- **🔧 Enhanced Maintainability:** Single source of truth
- **📖 Rich Documentation:** Self-documented actions
- **✨ Developer Experience:** Simplified workflows, focus on business logic

This architecture follows GitHub Actions best practices and provides a scalable foundation for the Sportiverse project's CI/CD needs.
