metadata name = 'Storage Account Construct'
metadata description = 'Construct for using a storage account with private endpoints, diagnostics, and common settings.'
metadata owner = 'Gullapalli-R'

targetScope = 'resourceGroup'

@description('The Geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Name of Storage Account. Must be unique within Azure.')
@minLength(3)
@maxLength(24)
param name string

@description('Storage SKU to use: https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types .')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param sku string = 'Standard_ZRS'

@description('Storage account type (usually should be StorageV2 except in more special cases).')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string = 'StorageV2'

@description('Enable Hierarchical Namespace (Azure Data Lake Storage v2). This cannot be changed once set to true.')
param hierarchicalNamespaceEnabled bool = false

@description('If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.')
param nfsV3Enabled bool = false

@description('Enable Secure File Transfer Protocol. This can be enabled only on hierarchicalnamespace enabled stg accounts.')
param sftpEnabled bool = false

@description('Whether or not to allow shared key access.')
param allowSharedKeyAccess bool = false

@description('The ID of the subnet from which the private IP will be allocated.')
param subnetId string

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('Resource ID for the log workspace if adding diagnostic settings')
param diagnosticLogWorkspaceId string = ''

@description('Indicates the number of days that the deleted item should be retained. The minimum specified value can be 1 and the maximum value can be 365.')
@minValue(1)
@maxValue(365)
param deleteRetentionPolicyDays int = 30

@description('Optional. The blob service properties for blob soft delete.')
param deleteRetentionPolicyEnabled bool = true

@description('This property when set to true allows deletion of the soft deleted blob versions and snapshots. This property cannot be used blob restore policy. This property only applies to blob service and does not apply to containers or file share.')
param allowPermanentDelete bool = true

@description('The Storage Account ManagementPolicies Rules. If not provided, a default lifecycle rule (default-rule-1) is applied. For HNS accounts the default includes baseBlob + snapshot tiering actions; for non-HNS accounts it also includes version tiering actions.')
param managementPolicyRules array?

@description('Create the specified private endpoints for the storage account. By default, will create endpoints for `blob`, and if you enable Hierarchical Namespaces, it will create `dfs` as well. Be careful to avoid adding duplicates, it will likely cause the deployment to fail, but won\'t tell you at compile time (yet).')
param privateEndpointGroupNames StoragePrivateEndpointGroupName[]?

@description('Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet.')
@allowed([
  'AAD'
  'PrivateLink'
])
param allowedCopyScope string = 'PrivateLink'

@description('Blob Containers to create with the storage account')
param containers ContainerType[] = []

@description('Optional. The blob service properties for container soft delete. Indicates whether DeleteRetentionPolicy is enabled.')
param containerDeleteRetentionPolicy bool = false
@minValue(1)
@maxValue(365)
@description('Optional. Indicates the number of days that the deleted containers should be retained.')
param containerDeleteRetentionPolicyDays int = 30

@description('This property when set to true allows deletion of the soft deleted containers.')
param allowContainerPermanentDelete bool = false

@description('Optional. Use versioning to automatically maintain previous versions of your blobs. Cannot be enabled for ADLS Gen2 storage accounts(hierarchicalNamespaceEnabled set to true).')
param isVersioningEnabled bool = false

@description('Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.')
@allowed([
  'Premium'
  'Hot'
  'Cool'
  'Cold'
])
param accessTier string = 'Hot'

@description('Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls networkAclsType?

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string?

// determine the default storage endpoint groups. If the storage endpoint groups parameter is null, then use the default automatically.
var defaultStorageEndpointGroups = concat(
  [
    'blob'
  ],
  hierarchicalNamespaceEnabled ? ['dfs'] : []
)

@description('Optional. Fileshares to create with the storage account')
param fileShares fileShare[]?

resource storage 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    accessTier: (kind != 'Storage' && kind != 'BlockBlobStorage') ? accessTier : null
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? any(publicNetworkAccess)
      : (!empty(privateEndpointGroupNames) && empty(networkAcls) ? 'Disabled' : null)
    allowBlobPublicAccess: false
    allowSharedKeyAccess: allowSharedKeyAccess
    allowCrossTenantReplication: false
    defaultToOAuthAuthentication: true
    isHnsEnabled: hierarchicalNamespaceEnabled
    isNfsV3Enabled: nfsV3Enabled
    isSftpEnabled: sftpEnabled
    allowedCopyScope: allowedCopyScope
    encryption: {
      keySource: 'Microsoft.Storage'

      // the following parameters can only be configured at deploy time
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
      }
      requireInfrastructureEncryption: true
    }
    networkAcls: !empty(networkAcls)
      ? {
          resourceAccessRules: networkAcls.?resourceAccessRules
          defaultAction: networkAcls.?defaultAction ?? 'Deny'
          virtualNetworkRules: networkAcls.?virtualNetworkRules
          ipRules: networkAcls.?ipRules
          bypass: networkAcls.?bypass
        }
      : {
          // Default firewall configuration
          bypass: 'AzureServices'
          defaultAction: 'Deny'
        }
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2025-06-01' = {
  parent: storage
  name: 'default'
}

resource fileshares 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-06-01' = [
  for fileshare in (fileShares ?? []): {
    parent: fileService
    name: fileshare.name
    properties: {
      accessTier: fileshare.?accessTier ?? 'TransactionOptimized'
      shareQuota: fileshare.?shareQuota ?? 1
      enabledProtocols: fileshare.?enabledProtocols ?? 'SMB'
      rootSquash: fileshare.?rootSquash ?? (fileshare.?enabledProtocols == 'NFS' ? fileshare.?rootSquash : null)
    }
  }
]

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' = {
  name: 'default'
  parent: storage
  properties: {
    deleteRetentionPolicy: {
      enabled: deleteRetentionPolicyEnabled
      days: deleteRetentionPolicyDays
      allowPermanentDelete: allowPermanentDelete
    }
    containerDeleteRetentionPolicy: {
      allowPermanentDelete: allowContainerPermanentDelete
      days: containerDeleteRetentionPolicyDays
      enabled: containerDeleteRetentionPolicy
    }
    isVersioningEnabled: !hierarchicalNamespaceEnabled ? isVersioningEnabled : false
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = [
  for (item, index) in containers: {
    name: item.name
    parent: blobServices
    properties: {
      publicAccess: 'None'
    }
  }
]

var defaultManagementNonHnsPolicyRules = [
  {
    definition: {
      actions: {
        baseBlob: {
          tierToCool: {
            daysAfterModificationGreaterThan: 90
          }
          tierToCold: {
            daysAfterModificationGreaterThan: 120
          }
        }
        snapshot: {
          tierToCool: {
            daysAfterCreationGreaterThan: 90
          }
          tierToCold: {
            daysAfterCreationGreaterThan: 120
          }
        }
        version: {
          tierToCool: {
            daysAfterCreationGreaterThan: 90
          }
          tierToCold: {
            daysAfterCreationGreaterThan: 120
          }
        }
      }
      filters: {
        blobTypes: [
          'blockBlob'
        ]
      }
    }
    enabled: true
    name: 'default-NonHns-rule-1'
    type: 'Lifecycle'
  }
]

var defaultManagementHnsPolicyRules = [
  {
    definition: {
      actions: {
        baseBlob: {
          tierToCool: {
            daysAfterModificationGreaterThan: 3650
          }
        }
        snapshot: {
          tierToCool: {
            daysAfterCreationGreaterThan: 3650
          }
        }
      }
      filters: {
        blobTypes: [
          'blockBlob'
        ]
      }
    }
    enabled: true
    name: 'default-Hns-rule-1'
    type: 'Lifecycle'
  }
]

module managementPolicies './modules/managementpolicy.bicep' = {
  name: take('${deployment().name}-ST-MP', 64)
  params: {
    storageAccountName: storage.name
    rules: managementPolicyRules ?? (hierarchicalNamespaceEnabled
      ? defaultManagementHnsPolicyRules
      : defaultManagementNonHnsPolicyRules)
  }
}

var blobCategories = [
  'allLogs'
  'audit'
]

resource diagnosticsblobServices 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticLogWorkspaceId)) {
  name: 'default-diagnostics'
  scope: blobServices
  properties: {
    workspaceId: diagnosticLogWorkspaceId
    logs: [
      for item in blobCategories: {
        enabled: true
        categoryGroup: item
      }
    ]
  }
}

var storageCategories = [
  'Transaction'
]

resource diagnosticsStorage 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticLogWorkspaceId)) {
  name: 'default-diagnostics'
  scope: storage
  properties: {
    workspaceId: diagnosticLogWorkspaceId
    metrics: [
      for item in storageCategories: {
        enabled: true
        category: item
      }
    ]
  }
}
module privateEndpoint '../private-endpoint/main.bicep' = [
  for (item, index) in privateEndpointGroupNames ?? defaultStorageEndpointGroups: {
    name: take('${deployment().name}-ST-PE-${item}-${index}', 64)
    params: {
      name: '${storage.name}-${item}-PE'
      location: location
      endpointGroupId: item
      serviceId: storage.id
      subnetId: subnetId
      tags: tags
    }
  }
]

@description('Identifier for the storage account')
output id string = storage.id

@description('Name of the storage account')
output name string = storage.name

type StoragePrivateEndpointGroupName = 'blob' | 'file' | 'table' | 'queue' | 'dfs'

type ContainerType = {
  @minLength(3)
  @maxLength(63)
  name: string
}

@export()
@description('The type for network ACLs configuration.')
type networkAclsType = {
  @description('Optional. Sets the resource access rules. Array entries must consist of "tenantId" and "resourceId" fields only.')
  resourceAccessRules: {
    @description('Required. The ID of the tenant in which the resource resides in.')
    tenantId: string
    @description('Required. The resource ID of the target service. Can also contain a wildcard, if multiple services e.g. in a resource group should be included.')
    resourceId: string
  }[]?

  @description('Optional. Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging, Metrics, AzureServices, or None.')
  bypass: string?

  @description('Optional. Sets the virtual network rules.')
  virtualNetworkRules: {
    @description('Required. The resource ID of the virtual network subnet.')
    id: string
    @description('Optional. The action of the virtual network rule.')
    action: ('Allow')?
  }[]?

  @description('Optional. Sets the IP ACL rules.')
  ipRules: {
    @description('Required. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed.')
    value: string
    @description('Optional. The action of the IP ACL rule.')
    action: ('Allow')?
  }[]?

  @description('Optional. Specifies the default action of allow or deny when no other rules match.')
  defaultAction: ('Allow' | 'Deny')?
}

@export()
@description('The type for a shared file')
type fileShare = {
  @description('Name of the fileShare')
  name: string

  @description('Conditional. Access tier for specific share. Required if the Storage Account kind is set to FileStorage (should be set to "Premium"). GpV2 account can choose between TransactionOptimized (default), Hot, and Cool.')
  accessTier: ('null' | 'Premium' | 'Hot' | 'Cool' | 'TransactionOptimized')?

  @description('Optional. The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5120 (5TB). For Large File Shares, the maximum size is 102400 (100TB).')
  shareQuota: int?

  @description('Optional. Permissions for NFS file shares are enforced by the client OS rather than the Azure Files service. Toggling the root squash behavior reduces the rights of the root user for NFS shares.')
  rootSquash: ('null' | 'AllSquash' | 'NoRootSquash' | 'RootSquash')?

  @description('Optional. The authentication protocol that is used for the file share. Can only be specified when creating a share.')
  enabledProtocols: ('null' | 'NFS' | 'SMB')?
}
