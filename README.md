# Azure IAC - Bicep Module Registry

This repository contains a curated collection of reusable **Bicep modules** and **stamps** (composite infrastructure patterns) for Azure Infrastructure as Code deployments. All modules are published to the Bicep Registry and can be referenced using module references.

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Modules](#modules)
  - [Constructs](#constructs)
  - [Stamps](#stamps)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Module Usage](#module-usage)
- [Testing](#testing)
- [CI/CD Workflows](#cicd-workflows)
- [Contributing](#contributing)
- [Support](#support)

---

## 🎯 Overview

**Azure IAC** is a comprehensive Bicep module registry designed to:

- Provide reusable, production-ready infrastructure components
- Enforce security best practices and compliance standards
- Enable fast, consistent infrastructure deployments across Azure
- Support multiple deployment environments (dev, stg, prd)
- Automate testing, validation, and publishing

**Key Features:**

- ✅ Private endpoint support for all services
- ✅ Built-in diagnostic logging
- ✅ Comprehensive tagging strategy
- ✅ Network security & isolation
- ✅ RBAC integration
- ✅ Automated testing & validation
- ✅ Published to Azure Bicep Registry

---

## 📁 Repository Structure

```
azure-iac/
├── modules/
│   ├── constructs/              # Base infrastructure components
│   │   ├── container-registry/
│   │   ├── log-analytics-workspace/
│   │   ├── private-endpoint/
│   │   ├── storage-account/
│   │   ├── virtual-machine/
│   │   └── virtual-network/
│   └── stamps/                  # Composite infrastructure patterns
│       └── platform-services/   # Core platform infrastructure
├── scripts/
│   ├── azure-pipelines/         # Azure Pipelines scripts
│   └── github-actions/          # GitHub Actions helpers
├── .github/
│   ├── workflows/               # CI/CD automation
│   ├── actions/                 # Custom GitHub Actions
│   └── ISSUE_TEMPLATE/
├── docs/                        # Documentation
└── README.md
```

---

## 🧩 Modules

### Constructs

**Constructs** are individual infrastructure building blocks. Each provides a single, focused Azure resource with opinionated defaults and best practices.

| Module                      | Description                                                                          | Version |
| --------------------------- | ------------------------------------------------------------------------------------ | ------- |
| **container-registry**      | Azure Container Registry with security features (quarantine, retention, soft delete) | 0.1.0   |
| **log-analytics-workspace** | Log Analytics Workspace for centralized monitoring & logging                         | 0.1.0   |
| **private-endpoint**        | Private endpoint for secure service connectivity                                     | 0.3.0   |
| **storage-account**         | Storage Account with lifecycle management, soft delete, and private endpoints        | 0.6.0   |
| **virtual-machine**         | Virtual Machine with extensions and protected items                                  | 1.0+    |
| **virtual-network**         | Virtual Network with subnets, NSGs, and route tables                                 | 1.0+    |

**Usage Example:**

```bicep
module storage 'br:bicepiacregistry.azurecr.io/bicep/constructs/storage-account:0.6.0' = {
  name: 'storageDeployment'
  params: {
    name: 'mystorageaccount'
    location: 'eastus'
    sku: 'Standard_ZRS'
    hierarchicalNamespaceEnabled: true
  }
}
```

---

### Stamps

**Stamps** are composite infrastructure patterns that combine multiple constructs into a cohesive deployment unit. Each stamp represents a complete, self-contained infrastructure pattern for a specific use case.

#### Platform-Services Stamp

The **Platform-Services** stamp deploys foundational infrastructure services for application workloads.

**Included Services:**

- 🔍 **Log Analytics Workspace** — Centralized logging & monitoring
- 💾 **Storage Account(s)** — Multi-purpose data storage (blob, file, ADLS Gen2)
- 📦 **Container Registry** — Private container image repository

**Key Features:**

- Private endpoints for all services
- Configurable daily ingestion quota for LAW
- Support for multiple storage accounts (blob, data lake, logs)
- Premium ACR SKU with advanced policies
- Automatic diagnostic logging
- Full network isolation via private link subnet

**Resource Naming Convention:**

- Log Analytics: `LOG-{ENVIRONMENT}-{NAME}` (e.g., `LOG-DEV01-PLATFORM`)
- Storage Account: `st{env}{name}{shortName}` (e.g., `stdev01platformdata`)
- Container Registry: `contreg{env}{name}{shortName}` (e.g., `contregdev01platformacr01`)

**Usage Example:**

```bicep
module platformServices 'br:bicepiacregistry.azurecr.io/bicep/stamps/platform-services:0.1.0' = {
  name: 'platformServicesDeployment'
  params: {
    environmentName: 'dev01'
    name: 'platform'
    location: 'eastus'
    vnet_resourceGroup: 'rg-network'
    vnet_name: 'vnet-hub'
    vnet_privateLinkSubnet: 'snet-private-link'

    storage_items: [
      { shortName: 'data', hierarchicalNamespaceEnabled: true }
      { shortName: 'logs', accessTier: 'Cool' }
    ]

    containerRegistry_items: [
      { shortName: '01', skuName: 'Premium' }
    ]
  }
}
```

---

## 📋 Prerequisites

- **Azure Subscription** — Active subscription with appropriate permissions
- **Bicep CLI** — v0.45+ installed (`az bicep install`)
- **Azure CLI** — Latest version
- **Git** — For cloning the repository
- **GitHub Credentials** — For CI/CD workflows (OIDC federation configured)

**Azure RBAC Requirements:**

- `Owner` or `Contributor` role on subscription/resource group
- Service Principal with federated credentials for GitHub Actions

**Network Prerequisites:**

- Existing VNet with private link subnet
- Network security configured for private endpoints

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/gullapalli-r/azure-iac.git
cd azure-iac
```

### 2. Install Dependencies

```bash
# Bicep CLI
az bicep install

# Node.js dependencies
npm install
```

### 3. Authenticate to Azure

```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

### 4. Validate Modules

```bash
bicep build modules/constructs/storage-account/main.bicep
```

---

## 📦 Module Usage

### Using Constructs

**Deploy Storage Account:**

```bicep
module storage 'br:bicepiacregistry.azurecr.io/bicep/constructs/storage-account:0.6.0' = {
  name: 'storageModule'
  params: {
    name: 'mystg${uniqueString(resourceGroup().id)}'
    location: location
    tags: tags
    subnetId: subnetId
    containers: [
      { name: 'data' }
      { name: 'logs' }
    ]
    fileShares: [
      { name: 'fileshare01' }
    ]
  }
}
```

**Deploy Container Registry:**

```bicep
module acr 'br:bicepiacregistry.azurecr.io/bicep/constructs/container-registry:0.1.0' = {
  name: 'acrModule'
  params: {
    name: toLower('acr${uniqueString(resourceGroup().id)}')
    location: location
    skuName: 'Premium'
    quarantinePolicyStatusEnabled: true
    retentionPolicyStatusEnabled: true
  }
}
```

---

## 🧪 Testing

### Run Bicep Validation

```bash
# Validate a single module
bicep build modules/constructs/storage-account/main.bicep

# Validate all modules
for module in modules/constructs/*/; do
  bicep build "$module/main.bicep"
done
```

### Run Module Tests via GitHub Actions

The repository includes automated testing via GitHub Actions:

1. Navigate to **Actions** → **Test Module**
2. Click **Run workflow**
3. Select:
   - **Module:** `stamps/platform-services`
   - **Operation:** `what_if` (dry-run) or `test_using_deployment_stack` (actual deploy)
4. View results in the workflow run

**Available Operations:**

- `what_if` — Dry-run validation (no changes)
- `test_using_deployment_stack` — Deploy with cleanup
- `cleanup_deployment_stack` — Remove test resources

### Manual Testing (Local)

```bash
# What-If deployment
az deployment group what-if \
  --resource-group rg-iac-eastus \
  --template-file modules/stamps/platform-services/test/main.test.bicep \
  --parameters modules/stamps/platform-services/test/main.test.pet.parameters.jsonc

# Actual deployment
az deployment group create \
  --resource-group rg-iac-eastus \
  --template-file modules/stamps/platform-services/test/main.test.bicep \
  --parameters modules/stamps/platform-services/test/main.test.pet.parameters.jsonc
```

---

## 🔄 CI/CD Workflows

### Available Workflows

| Workflow                          | Trigger        | Purpose                       |
| --------------------------------- | -------------- | ----------------------------- |
| **on-push-main.yml**              | Push to main   | Build, test, publish modules  |
| **on-pull-request.yml**           | PR to main     | Validate changes, run tests   |
| **fork-on-push-brm-generate.yml** | Push to branch | Auto-generate Bicep files     |
| **test-module.yml**               | Manual trigger | Deploy & test specific module |
| **publish-module.yml**            | Manual trigger | Publish module to registry    |

### GitHub Secrets Required

Configure these in **Settings → Secrets and variables → Actions:**

```
AZURE_CLIENT_ID          # Service principal client ID
AZURE_TENANT_ID          # Azure AD tenant ID
AZURE_SUBSCRIPTION_ID    # Azure subscription ID
```

### Environment Secrets

Configure in **Settings → Environments → rg-iac-eastus:**

```
AZURE_CLIENT_ID
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
```

---

## 👥 Contributing

### Create a New Module

1. **Create module directory:**

   ```bash
   mkdir -p modules/constructs/my-module/test
   ```

2. **Add required files:**

   - `main.bicep` — Module definition
   - `README.md` — Documentation
   - `CHANGELOG.md` — Version history
   - `version.json` — Version metadata
   - `test/main.test.bicep` — Test file
   - `test/main.test.pet.parameters.jsonc` — Test parameters

3. **Validate:**

   ```bash
   bicep build modules/constructs/my-module/main.bicep
   ```

4. **Run tests:**
   - Push to feature branch
   - Create PR to main
   - GitHub Actions will validate automatically

### Module Standards

- ✅ All resources must have diagnostics enabled
- ✅ Private endpoints for all services
- ✅ Tagging strategy enforced
- ✅ RBAC role assignments documented
- ✅ Secrets/passwords never hardcoded
- ✅ Version.json updated with semantic versioning

---

## 🆘 Support

- **Documentation:** See individual module READMEs
- **Issues:** GitHub Issues for bugs/feature requests
- **Security:** See SECURITY.md for vulnerability reporting

---

## 📄 License

See [bicep-module-registry.LICENSE](bicep-module-registry.LICENSE)

---

## 👤 Owner

**Gullapalli-R**

---

## 📊 Repository Stats

- **Modules:** 11 (6 Constructs, 1 Stamp)
- **Total Deployments:** 100+
- **Latest Version:** 0.1.0
- **Last Updated:** 2026-07-14
