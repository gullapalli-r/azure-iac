# Storage Account Construct

Construct for using a storage account with private endpoints, diagnostics, and common settings.

## Details

{{Add detailed information about the module}}

Storage Account Construct Parameters Guide

Required parameters

name: Storage account name, 3 to 24 chars, globally unique.
subnetId: Subnet resource ID for private endpoint creation.
Core optional parameters

location: Defaults to resource group location.
sku: Standard_ZRS default. Allowed values include Standard_LRS, Standard_GRS, Standard_RAGRS, Standard_GZRS, Standard_RAGZRS, Premium_LRS, Premium_ZRS.
kind: StorageV2 default. Allowed values include BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2.
tags: Key/value object.
diagnosticLogWorkspaceId: Log Analytics workspace resource ID.
publicNetworkAccess: Enabled or Disabled.
allowedCopyScope: AAD or PrivateLink (default PrivateLink).
Data protection optional parameters

deleteRetentionPolicyEnabled: Default true.
deleteRetentionPolicyDays: 1 to 365, default 30.
allowPermanentDelete: Default true.
containerDeleteRetentionPolicy: Default false.
containerDeleteRetentionPolicyDays: 1 to 365, default 30.
allowContainerPermanentDelete: Default false.
isVersioningEnabled: Default false, and disabled automatically when hierarchicalNamespaceEnabled is true.
Protocol and namespace optional parameters

hierarchicalNamespaceEnabled: Default false.
nfsV3Enabled: Default false, requires hierarchicalNamespaceEnabled true.
sftpEnabled: Default false.
allowSharedKeyAccess: Default false.
Network optional parameters

networkAcls:
defaultAction: Allow or Deny.
bypass: Logging, Metrics, AzureServices, None, or combinations.
virtualNetworkRules: Array of objects with id and optional action Allow.
ipRules: Array of objects with value (CIDR) and optional action Allow.
resourceAccessRules: Array of objects with tenantId and resourceId.
privateEndpointGroupNames: Any of blob, file, table, queue, dfs. If omitted, default is blob, plus dfs when hierarchical namespace is enabled.
Resource creation optional parameters

containers: Array of objects with name.
fileShares: Array of objects with:
name
accessTier: Premium, Hot, Cool, TransactionOptimized
shareQuota
enabledProtocols: SMB or NFS
rootSquash: AllSquash, NoRootSquash, RootSquash
Management policy rules optional parameter

managementPolicyRules is an array of lifecycle rules.
If omitted, the module applies default lifecycle rules automatically.
Each rule object should include:
name: Rule name
enabled: true or false
type: Lifecycle
definition:
filters:
blobTypes: usually blockBlob
actions:
baseBlob: tierToCool, tierToCold, tierToArchive, delete
snapshot: tierToCool, tierToCold, tierToArchive, delete
version: tierToCool, tierToCold, tierToArchive, delete

Minimal parameters.json example

{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": { "value": "stbrmtest01" },
    "subnetId": { "value": "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>" },
    "tags": { "value": { "env": "dev" } }
  }
}

Full

{
"$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
"contentVersion": "1.0.0.0",
"parameters": {
"location": {
"value": "eastus"
},
"name": {
"value": "stbrmtest01"
},
"sku": {
"value": "Standard_ZRS"
},
"kind": {
"value": "StorageV2"
},
"hierarchicalNamespaceEnabled": {
"value": false
},
"nfsV3Enabled": {
"value": false
},
"sftpEnabled": {
"value": false
},
"allowSharedKeyAccess": {
"value": false
},
"subnetId": {
"value": "/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"
},
"tags": {
"value": {
"env": "dev",
"app": "poc"
}
},
"diagnosticLogWorkspaceId": {
"value": "/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<law>"
},
"deleteRetentionPolicyDays": {
"value": 30
},
"deleteRetentionPolicyEnabled": {
"value": true
},
"allowPermanentDelete": {
"value": true
},
"managementPolicyRules": {
"value": [
{
"name": "lifecycle-rule-1",
"enabled": true,
"type": "Lifecycle",
"definition": {
"filters": {
"blobTypes": [
"blockBlob"
]
},
"actions": {
"baseBlob": {
"tierToCool": {
"daysAfterModificationGreaterThan": 30
},
"tierToCold": {
"daysAfterModificationGreaterThan": 90
},
"tierToArchive": {
"daysAfterModificationGreaterThan": 180
}
},
"snapshot": {
"tierToCool": {
"daysAfterCreationGreaterThan": 30
},
"tierToArchive": {
"daysAfterCreationGreaterThan": 180
}
},
"version": {
"tierToCool": {
"daysAfterCreationGreaterThan": 30
}
}
}
}
}
]
},
"privateEndpointGroupNames": {
"value": [
"blob",
"file"
]
},
"allowedCopyScope": {
"value": "PrivateLink"
},
"containers": {
"value": [
{
"name": "raw"
},
{
"name": "curated"
}
]
},
"containerDeleteRetentionPolicy": {
"value": true
},
"containerDeleteRetentionPolicyDays": {
"value": 30
},
"allowContainerPermanentDelete": {
"value": false
},
"isVersioningEnabled": {
"value": true
},
"accessTier": {
"value": "Hot"
},
"networkAcls": {
"value": {
"defaultAction": "Deny",
"bypass": "AzureServices",
"virtualNetworkRules": [
{
"id": "/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>",
"action": "Allow"
}
],
"ipRules": [
{
"value": "10.10.10.0/24",
"action": "Allow"
}
],
"resourceAccessRules": [
{
"tenantId": "<tenantGuid>",
"resourceId": "/subscriptions/<subId>/resourceGroups/<rg>/providers/Microsoft.Synapse/workspaces/<workspace>"
}
]
}
},
"publicNetworkAccess": {
"value": "Disabled"
},
"fileShares": {
"value": [
{
"name": "appshare",
"accessTier": "TransactionOptimized",
"shareQuota": 100,
"enabledProtocols": "SMB"
},
{
"name": "nfsshare",
"accessTier": "Premium",
"shareQuota": 1024,
"enabledProtocols": "NFS",
"rootSquash": "RootSquash"
}
]
}
}
}

Important constraints while filling values:

name and subnetId are required.
nfsV3Enabled and sftpEnabled need hierarchicalNamespaceEnabled true.
isVersioningEnabled should stay false when hierarchicalNamespaceEnabled is true.
accessTier is mainly relevant when kind is BlobStorage.
container and blob retention days must be 1 to 365.



## Parameters

| Name                                 | Type            | Required | Description                                                                                                                                                                                                                                                                                                                                     |
| :----------------------------------- | :-------------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                           | `string`        | No       | The Geo-location where the resource lives.                                                                                                                                                                                                                                                                                                      |
| `name`                               | `string`        | Yes      | Name of Storage Account. Must be unique within Azure.                                                                                                                                                                                                                                                                                           |
| `sku`                                | `string`        | No       | Storage SKU to use: https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types .                                                                                                                                                                                                                                                        |
| `kind`                               | `string`        | No       | Storage account type (usually should be StorageV2 except in more special cases).                                                                                                                                                                                                                                                                |
| `hierarchicalNamespaceEnabled`       | `bool`          | No       | Enable Hierarchical Namespace (Azure Data Lake Storage v2). This cannot be changed once set to true.                                                                                                                                                                                                                                            |
| `nfsV3Enabled`                       | `bool`          | No       | If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.                                                                                                                                                                                                                                      |
| `sftpEnabled`                        | `bool`          | No       | Enable Secure File Transfer Protocol. This can be enabled only on hierarchicalnamespace enabled stg accounts.                                                                                                                                                                                                                                   |
| `allowSharedKeyAccess`               | `bool`          | No       | Whether or not to allow shared key access.                                                                                                                                                                                                                                                                                                      |
| `subnetId`                           | `string`        | Yes      | The ID of the subnet from which the private IP will be allocated.                                                                                                                                                                                                                                                                               |
| `tags`                               | `object`        | No       | Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters. |
| `diagnosticLogWorkspaceId`           | `string`        | No       | Resource ID for the log workspace if adding diagnostic settings                                                                                                                                                                                                                                                                                 |
| `deleteRetentionPolicyDays`          | `int`           | No       | Indicates the number of days that the deleted item should be retained. The minimum specified value can be 1 and the maximum value can be 365.                                                                                                                                                                                                   |
| `deleteRetentionPolicyEnabled`       | `bool`          | No       | Optional. The blob service properties for blob soft delete.                                                                                                                                                                                                                                                                                     |
| `allowPermanentDelete`               | `bool`          | No       | This property when set to true allows deletion of the soft deleted blob versions and snapshots. This property cannot be used blob restore policy. This property only applies to blob service and does not apply to containers or file share.                                                                                                    |
| `managementPolicyRules`              | `array | null`  | No       | The Storage Account ManagementPolicies Rules. If not provided, a default lifecycle rule (default-rule-1) is applied. For HNS accounts the default includes baseBlob + snapshot tiering actions; for non-HNS accounts it also includes version tiering actions.                                                                                  |
| `privateEndpointGroupNames`          | `array | null`  | No       | Create the specified private endpoints for the storage account. By default, will create endpoints for `blob`, and if you enable Hierarchical Namespaces, it will create `dfs` as well. Be careful to avoid adding duplicates, it will likely cause the deployment to fail, but won't tell you at compile time (yet).                            |
| `allowedCopyScope`                   | `string`        | No       | Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet.                                                                                                                                                                                                                                         |
| `containers`                         | `array`         | No       | Blob Containers to create with the storage account                                                                                                                                                                                                                                                                                              |
| `containerDeleteRetentionPolicy`     | `bool`          | No       | Optional. The blob service properties for container soft delete. Indicates whether DeleteRetentionPolicy is enabled.                                                                                                                                                                                                                            |
| `containerDeleteRetentionPolicyDays` | `int`           | No       | Optional. Indicates the number of days that the deleted containers should be retained.                                                                                                                                                                                                                                                          |
| `allowContainerPermanentDelete`      | `bool`          | No       | This property when set to true allows deletion of the soft deleted containers.                                                                                                                                                                                                                                                                  |
| `isVersioningEnabled`                | `bool`          | No       | Optional. Use versioning to automatically maintain previous versions of your blobs. Cannot be enabled for ADLS Gen2 storage accounts(hierarchicalNamespaceEnabled set to true).                                                                                                                                                                 |
| `accessTier`                         | `string`        | No       | Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.                                                            |
| `networkAcls`                        | `null | object` | No       | Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny.                                                                                                                                         |
| `publicNetworkAccess`                | `null | string` | No       | Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.                                                                                                             |
| `fileShares`                         | `null | array`  | No       | Optional. Fileshares to create with the storage account                                                                                                                                                                                                                                                                                         |

## Outputs

| Name   | Type     | Description                        |
| :----- | :------: | :--------------------------------- |
| `id`   | `string` | Identifier for the storage account |
| `name` | `string` | Name of the storage account        |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```