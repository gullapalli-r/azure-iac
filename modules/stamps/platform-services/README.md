# platform-services

Stamp for platform-services, allowing for multiple required resources.

## Details

Platform-Services Stamp - Details & Purpose

The platform-services stamp is a foundational infrastructure module that deploys core platform services required for application workloads. It provides centralized logging, data storage, and container image management capabilities within a secure, network-isolated environment.

Services Included

Log Analytics Workspace (LAW)

Centralized logging and monitoring for all platform resources
Configurable daily quota (default: 24 GB)
Security features: Disabled local auth, resource permission-based access
Serves as the diagnostic destination for storage and other services

Storage Account(s)

Multi-purpose data storage with support for:
Blob storage with lifecycle management
File shares (SMB & NFS protocols)
Hierarchical namespace (ADLS Gen2) support
SFTP and NFS v3.0 capabilities
Private endpoints for secure, network-isolated access
Soft delete policies for data protection
Diagnostic logging to LAW
Supports multiple storage accounts per stamp (via array parameter)

Container Registry (ACR)

Premium SKU with advanced security features:
Quarantine policy for image scanning
Retention policy for cleanup
Soft delete for accidental deletion recovery
Zone redundancy option
Private endpoints for secure image pulls
Supports multiple registries per stamp (via array parameter)
Trusted services bypass for internal Azure services

Key Characteristics

## Parameters

| Name                                  | Type     | Required | Description                                                                                                                                                                                                                                                                                                                                     |
| :------------------------------------ | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                            | `string` | No       | Geo-location of the resources.                                                                                                                                                                                                                                                                                                                  |
| `environmentName`                     | `string` | Yes      | Environment identifier representing the deployment stage (e.g., dev, stg, prd). Used to categorize and organize resources across different deployment environments. This value is incorporated into resource names for easy identification and tracking.                                                                                        |
| `name`                                | `string` | No       | Workload or service identifier for this platform-services stamp (e.g., infra, core, platform). Used to distinguish multiple platform-services stamps within the same environment. This value is incorporated into resource names to enable multiple deployments without conflicts.                                                              |
| `vnet_resourceGroup`                  | `string` | Yes      | Name of the resource group of the virtual network.                                                                                                                                                                                                                                                                                              |
| `vnet_name`                           | `string` | Yes      | Name of the virtual network.                                                                                                                                                                                                                                                                                                                    |
| `vnet_privateLinkSubnet`              | `string` | Yes      | Name of the Private Link subnet.                                                                                                                                                                                                                                                                                                                |
| `enableLogWorkspace`                  | `bool`   | No       | Enable Log Workspace.                                                                                                                                                                                                                                                                                                                           |
| `enableStorage`                       | `bool`   | No       | Enable Storage.                                                                                                                                                                                                                                                                                                                                 |
| `enableContainerRegistry`             | `bool`   | No       | Enable Container Registry.                                                                                                                                                                                                                                                                                                                      |
| `tags`                                | `object` | No       | Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters. |
| `dailyQuotaGb`                        | `int`    | No       | The workspace daily quota for ingestion. Default value is 24.                                                                                                                                                                                                                                                                                   |
| `enableLogAnalyticsWorkspaceFeatures` | `object` | No       | Optional. The workspace features.                                                                                                                                                                                                                                                                                                               |
| `storage_items`                       | `array`  | No       | Storage Accounts to deploy.                                                                                                                                                                                                                                                                                                                     |
| `containerRegistry_items`             | `array`  | No       | Container Registries to deploy.                                                                                                                                                                                                                                                                                                                 |

## Outputs

| Name                | Type     | Description              |
| :------------------ | :------: | :----------------------- |
| `log`               | `object` | Log Analytics Workspace. |
| `storage`           | `array`  | Storage Accounts.        |
| `containerRegistry` | `array`  | Container Registries.    |

## Examples

### Example 1

```bicep

/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

@description('Environment identifier representing the deployment stage (e.g., dev, stg, prd). Used to categorize and organize resources across different deployment environments. This value is incorporated into resource names for easy identification and tracking.')
param environmentName string = 'dev01'

@description('Workload or service identifier for this platform-services stamp (e.g., infra, core, platform). Used to distinguish multiple platform-services stamps within the same environment. This value is incorporated into resource names to enable multiple deployments without conflicts.')
param name string = 'platform'

@description('Deployment Location')
param location string = resourceGroup().location

// Network Settings
@description('Name of the resource group of the virtual network.')
param vnet_resourceGroup string

@description('Name of the virtual network.')
param vnet_name string

@description('Name of the Private Link subnet.')
param vnet_privateLinkSubnet string

var devTag = {
  'brm.env': 'dev'
}

module data '../main.bicep' = {
  name: '${deployment().name}-INFRA'
  params: {
    location: location
    name: name
    tags: devTag
    environmentName: environmentName
    vnet_name: vnet_name
    vnet_privateLinkSubnet: vnet_privateLinkSubnet
    vnet_resourceGroup: vnet_resourceGroup

    enableLogWorkspace: true
    enableStorage: true
    enableContainerRegistry: true

    storage_items: [
      {
        name: 'stbrmtestpet1'
        hierarchicalNamespaceEnabled: false
        allowedCopyScope: 'PrivateLink'
        sftpEnabled: false
        accessTier: 'Cool'
        containerDeleteRetentionPolicy: true
        allowContainerPermanentDelete: true
        containerDeleteRetentionPolicyDays: 30
        isVersioningEnabled: true
        deleteRetentionPolicyDays: 2
        fileShares: [
          {
            name: 'filesharetest1'
          }
          {
            name: 'filesharetest2'
          }
        ]
        containers: [
          {
            name: 'testcontainer1'
          }
          {
            name: 'testcontainer2'
          }
        ]
        tags: devTag
      }
      {
        name: 'stbrmtestpet2'
        accessTier: 'Hot'
        hierarchicalNamespaceEnabled: true
        allowedCopyScope: 'PrivateLink'
        sftpEnabled: true
        containerDeleteRetentionPolicy: true
        allowContainerPermanentDelete: true
        containerDeleteRetentionPolicyDays: 30
        isVersioningEnabled: true
        deleteRetentionPolicyDays: 2
        fileShares: [
          {
            name: 'filesharetest1'
          }
          {
            name: 'filesharetest2'
          }
        ]
        containers: [
          {
            name: 'testcontainer1'
          }
          {
            name: 'testcontainer2'
          }
        ]
        tags: devTag
      }
    ]

    containerRegistry_items: [
      {
        shortName: 'acr01'
        skuName: 'Premium'
        adminUserEnabled: false
        quarantinePolicyStatusEnabled: true
        retentionPolicyStatusEnabled: true
        retentionPolicyDays: 30
        exportPolicyStatusEnabled: false
        softDeletePolicyStatusEnabled: true
        softDeletePolicyDays: 30
        trustedServicesBypassEnabled: true
        zoneRedundancyEnabled: false
        anonymousPullEnabled: false
        tags: devTag
      }
    ]
  }
}

```

### Example 2

```bicep
```