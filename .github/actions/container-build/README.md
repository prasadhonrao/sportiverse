# Container Build Custom Action

## 🐳 Comprehensive Docker Container Solution

This custom action provides **enterprise-grade container building** with advanced features that go far beyond the simple `dockerize.yml` workflow.

## ✨ Features

### 🔧 **Advanced Build Features**

- **Multi-architecture builds** (ARM64, AMD64)
- **Multi-stage build support** with target selection
- **Build arguments and labels** with automatic metadata
- **External caching** for faster builds
- **Build time tracking** and performance metrics

### 🛡️ **Security & Compliance**

- **Integrated security scanning** using your docker-security action
- **SBOM generation** (Software Bill of Materials)
- **Provenance attestation** for supply chain security
- **Security scoring** with configurable thresholds

### 📦 **Multi-Registry Support**

- **Docker Hub** (docker.io)
- **GitHub Container Registry** (ghcr.io)
- **Azure Container Registry** (ACR)
- **Custom registries** with flexible configuration

### 📊 **Observability**

- **Detailed build summaries** in GitHub Actions
- **Image inspection** with size and layer analysis
- **Build duration tracking**
- **Comprehensive logging** and error handling

## 🚀 Usage Examples

### Basic Usage (replaces dockerize.yml)

```yaml
- name: Build and Push Container
  uses: ./.github/actions/container-build
  with:
    source-path: 'src/webapi'
    image-name: 'sportiverse-webapi'
    image-tag: ${{ github.sha }}
    registry-username: ${{ secrets.DOCKER_USERNAME }}
    registry-password: ${{ secrets.DOCKER_PASSWORD }}
```

### Advanced Multi-Registry Build

```yaml
- name: Build and Push to GHCR
  uses: ./.github/actions/container-build
  with:
    source-path: 'src/webapp'
    image-name: 'sportiverse-webapp'
    image-tag: 'latest'
    registry: 'ghcr'
    platforms: 'linux/amd64,linux/arm64'
    registry-username: ${{ github.actor }}
    registry-password: ${{ secrets.GITHUB_TOKEN }}
    build-args: 'NODE_ENV=production,VERSION=${{ github.sha }}'
    run-security-scan: 'true'
    security-fail-threshold: 'HIGH'
```

### Production Build with Caching

```yaml
- name: Production Container Build
  uses: ./.github/actions/container-build
  with:
    source-path: 'src/webapi'
    dockerfile-path: 'Dockerfile.prod'
    image-name: 'sportiverse-webapi'
    image-tag: ${{ github.ref_name }}
    registry: 'acr'
    registry-url: 'sportiverse.azurecr.io'
    registry-username: ${{ secrets.ACR_USERNAME }}
    registry-password: ${{ secrets.ACR_PASSWORD }}
    target: 'production'
    cache-from: 'type=gha'
    cache-to: 'type=gha,mode=max'
    labels: 'environment=production,team=backend'
    provenance: 'true'
    sbom: 'true'
```

## 📋 Input Parameters

| Parameter           | Description                        | Default       | Required |
| ------------------- | ---------------------------------- | ------------- | -------- |
| `source-path`       | Source code directory              | -             | ✅       |
| `image-name`        | Docker image name                  | -             | ✅       |
| `image-tag`         | Image tag                          | `latest`      | ❌       |
| `registry`          | Registry type (dockerhub/ghcr/acr) | `dockerhub`   | ❌       |
| `platforms`         | Target platforms                   | `linux/amd64` | ❌       |
| `build-args`        | Build arguments (comma-separated)  | -             | ❌       |
| `run-security-scan` | Enable security scanning           | `true`        | ❌       |
| `push-image`        | Push to registry                   | `true`        | ❌       |

## 📤 Outputs

| Output            | Description                   |
| ----------------- | ----------------------------- |
| `image-digest`    | Built image digest            |
| `image-full-name` | Full image name with registry |
| `image-size`      | Image size in bytes           |
| `security-score`  | Security scan score (0-100)   |
| `build-duration`  | Build time in seconds         |

## 🔄 Migration from dockerize.yml

### Before (Simple Workflow)

```yaml
- uses: ./.github/workflows/dockerize.yml
  with:
    source-code-path: 'src/webapi'
    docker-image: 'myapp:latest'
  secrets:
    DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
    DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

### After (Container Custom Action)

```yaml
- uses: ./.github/actions/container-build
  with:
    source-path: 'src/webapi'
    image-name: 'myapp'
    image-tag: 'latest'
    registry-username: ${{ secrets.DOCKER_USERNAME }}
    registry-password: ${{ secrets.DOCKER_PASSWORD }}
    run-security-scan: 'true' # 🆕 Built-in security
    platforms: 'linux/amd64,linux/arm64' # 🆕 Multi-arch
```

## 🎯 Benefits Over dockerize.yml

| Feature                 | dockerize.yml | container-build Action |
| ----------------------- | ------------- | ---------------------- |
| **Basic Build**         | ✅            | ✅                     |
| **Multi-Registry**      | ❌            | ✅                     |
| **Security Scanning**   | ❌            | ✅                     |
| **Multi-Architecture**  | ❌            | ✅                     |
| **Build Caching**       | ❌            | ✅                     |
| **SBOM/Provenance**     | ❌            | ✅                     |
| **Performance Metrics** | ❌            | ✅                     |
| **Error Handling**      | Basic         | Advanced               |

This container action provides a **complete container lifecycle solution** that's ready for enterprise production use! 🚀
