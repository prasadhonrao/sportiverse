# Node.js CI Pipeline Action

A comprehensive GitHub Action for Node.js continuous integration that handles linting, security auditing, testing, coverage reporting, and production builds.

## 🚀 Features

- **🔍 Code Quality**: ESLint linting with configurable rules
- **🔒 Security**: NPM/Yarn/PNPM vulnerability auditing
- **🧪 Testing**: Unit test execution with coverage reporting
- **📊 Coverage**: Codecov integration for coverage tracking
- **📦 Building**: Production-ready deployment package creation
- **⚡ Performance**: Optimized caching and dependency management
- **🔧 Flexibility**: Support for npm, yarn, and pnpm package managers

## 📝 Usage

```yaml
name: CI Pipeline
on: [push, pull_request]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Node.js CI
        uses: ./.github/actions/node-ci
        with:
          working-directory: 'src/api'
          node-version: '22'
          package-manager: 'npm'
```

## 🔧 Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `working-directory` | Working directory for the Node.js project | ✅ Yes | - |
| `node-version` | Node.js version to use | ❌ No | `'22'` |
| `package-manager` | Package manager (npm, yarn, pnpm) | ❌ No | `'npm'` |
| `skip-tests` | Skip running tests | ❌ No | `'false'` |
| `upload-coverage` | Upload coverage to Codecov | ❌ No | `'true'` |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `artifact-name` | Name of the uploaded build artifact |
| `artifact-url` | URL of the uploaded artifact |
| `quality-passed` | Whether quality gates passed |
| `test-results` | Test execution results (passed/skipped) |
| `coverage-percentage` | Test coverage percentage |

## 📋 Prerequisites

Your Node.js project should have these npm scripts defined in `package.json`:

```json
{
  "scripts": {
    "lint": "eslint .",
    "test": "jest",
    "test:coverage": "jest --coverage"
  }
}
```

## 🔄 Complete Example

```yaml
name: Full CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    outputs:
      artifact-name: ${{ steps.ci.outputs.artifact-name }}
      quality-passed: ${{ steps.ci.outputs.quality-passed }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Run CI Pipeline
        id: ci
        uses: ./.github/actions/node-ci
        with:
          working-directory: 'src/webapi'
          node-version: '22'
          package-manager: 'npm'
          upload-coverage: 'true'
      
      - name: Check Quality Gate
        if: steps.ci.outputs.quality-passed != 'true'
        run: |
          echo "❌ Quality gate failed"
          exit 1

  deploy:
    needs: ci
    if: github.ref == 'refs/heads/main' && needs.ci.outputs.quality-passed == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: echo "🚀 Deploying ${{ needs.ci.outputs.artifact-name }}"
```

## 🛠️ Customization

### Package Manager Support
The action automatically detects and uses the specified package manager:
- **npm**: Uses `npm ci`, `npm run lint`, `npm test`
- **yarn**: Uses `yarn install --frozen-lockfile`, `yarn lint`, `yarn test`
- **pnpm**: Uses `pnpm install --frozen-lockfile`, `pnpm lint`, `pnpm test`

### Security Audit Levels
Security audits run with moderate severity level:
- **npm**: `npm audit --audit-level=moderate`
- **yarn**: `yarn audit --level moderate`
- **pnpm**: `pnpm audit --audit-level moderate`

### Build Optimization
The production build excludes development files:
- Test files (`*.test.js`, `*.spec.js`, `__tests__/*`)
- Coverage reports (`coverage/*`)
- Development configs (`.eslintrc*`, `jest.config.js`)
- Documentation (`*.md`)
- Git files (`.git/*`, `.github/*`)

## 🎯 Integration with Other Actions

This action works seamlessly with other Sportiverse actions:

```yaml
- name: Node.js CI
  id: ci
  uses: ./.github/actions/node-ci
  with:
    working-directory: 'src/api'

- name: Deploy to Azure
  uses: ./.github/actions/deploy-azure-app
  with:
    artifact-name: ${{ steps.ci.outputs.artifact-name }}
    environment: 'production'

- name: Health Check
  uses: ./.github/actions/health-check
  with:
    endpoint: 'https://api.sportiverse.com/health'
```
