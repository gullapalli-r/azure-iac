metadata name = 'platform-services'
metadata description = 'Stamp for platform-services, allowing for multiple required resources.'
metadata owner = 'Gullapalli-R'

targetScope = 'resourceGroup'

@description('Geo-location of the resources.')
param location string = resourceGroup().location

@description('Name for the environment, this is the container for the application and data stamps and can be like: `np01`, `stg02`, `demo01`. It may not have an index at first, but could later. Keep this short as it is used for generating names. Use DNS segment naming rules.')
param environmentName string

@description('Name for the application stamp, default `app`. This will be used to generate automatic names for resources. If deploying multiple application stamps into an environment, make sure to change this to avoid overwriting resources. Use DNS segment naming rules.')
param name string = 'platform01'

// Network Settings
@description('Name of the resource group of the virtual network.')
param vnet_resourceGroup string

@description('Name of the virtual network.')
param vnet_name string

@description('Name of the Private Link subnet.')
param vnet_privateLinkSubnet string

var subnet_privateLink = resourceId(
  vnet_resourceGroup,
  'Microsoft.Network/virtualNetworks/subnets',
  vnet_name,
  vnet_privateLinkSubnet
)

// Enable / Disable Flags
@description('Enable Log Workspace.')
param enableLogWorkspace bool = true
@description('Enable Storage.')
param enableStorage bool = true
@description('Enable Container Registry.')
param enableContainerRegistry bool = true

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('The workspace daily quota for ingestion. Default value is 24.')
@minValue(-1)
param dailyQuotaGb int = 24

@description('Optional. The workspace features.')
param enableLogAnalyticsWorkspaceFeatures workspaceFeaturesType = {
  disableLocalAuth: true
  enableLogAccessUsingOnlyResourcePermissions: true
}

// Log Workspace
module log 'br:bicepiacregistry.azurecr.io/bicep/constructs/log-analytics-workspace:0.1.0' = if (enableLogWorkspace) {
  name: '${deployment().name}-LOG'
  params: {
    name: 'LOG-${toUpper(environmentName)}-${toUpper(name)}'
    location: location
    tags: tags
    dailyQuotaGb: dailyQuotaGb
    features: {
      disableLocalAuth: enableLogAnalyticsWorkspaceFeatures.?disableLocalAuth ?? true
      enableLogAccessUsingOnlyResourcePermissions: enableLogAnalyticsWorkspaceFeatures.?enableLogAccessUsingOnlyResourcePermissions ?? true
    }
  }
}

// Storage Account
@description('Storage Accounts to deploy.')
param storage_items StorageConfiguration[] = []

module storage 'br:bicepiacregistry.azurecr.io/bicep/constructs/storage-account:0.6.0' = [
  for (item, index) in (enableStorage ? storage_items : []): {
    name: '${deployment().name}-ST-${index}'
    params: {
      name: item.name
      location: location
      tags: (item.?tags ?? tags)
      subnetId: subnet_privateLink
      hierarchicalNamespaceEnabled: item.?hierarchicalNamespaceEnabled ?? false
      allowSharedKeyAccess: item.?allowSharedKeyAccess ?? false
      sku: item.?sku ?? 'Standard_LRS'
      kind: item.?kind ?? 'StorageV2'
      accessTier: item.?accessTier ?? 'Hot'
      nfsV3Enabled: item.?nfsV3Enabled ?? false
      sftpEnabled: item.?sftpEnabled ?? false
      allowedCopyScope: item.?allowedCopyScope ?? 'PrivateLink'
      privateEndpointGroupNames: item.?privateEndpointGroupNames
      containers: item.?containers
      deleteRetentionPolicyDays: item.?deleteRetentionPolicyDays ?? 30
      managementPolicyRules: item.?managementPolicyRules
      deleteRetentionPolicyEnabled: item.?deleteRetentionPolicyEnabled ?? true
      diagnosticLogWorkspaceId: item.?diagnosticLogWorkspaceId
      fileShares: item.?fileShares
      allowContainerPermanentDelete: item.?allowContainerPermanentDelete ?? false
      containerDeleteRetentionPolicy: item.?containerDeleteRetentionPolicy ?? false
      containerDeleteRetentionPolicyDays: item.?containerDeleteRetentionPolicyDays ?? 30
      networkAcls: item.?networkAcls
      publicNetworkAccess: item.?publicNetworkAccess ?? 'Disabled'
      isVersioningEnabled: item.?isVersioningEnabled ?? false
    }
  }
]

// Container Registry
@description('Container Registries to deploy.')
param containerRegistry_items ContainerRegistryConfiguration[] = []

module containerRegistry 'br:bicepiacregistry.azurecr.io/bicep/constructs/container-registry:0.1.0' = [
  for (item, index) in (enableContainerRegistry ? containerRegistry_items : []): {
    name: '${deployment().name}-ACR-${index}'
    params: {
      name: toLower('contreg${replace(environmentName, '-', '')}${replace(name, '-', '')}${item.shortName}')
      location: location
      tags: (item.?tags ?? tags)
      subnetId: subnet_privateLink
      skuName: item.?skuName ?? 'Premium'
      adminUserEnabled: item.?adminUserEnabled ?? false
      quarantinePolicyStatusEnabled: item.?quarantinePolicyStatusEnabled ?? false
      retentionPolicyStatusEnabled: item.?retentionPolicyStatusEnabled ?? false
      retentionPolicyDays: item.?retentionPolicyDays ?? 7
      exportPolicyStatusEnabled: item.?exportPolicyStatusEnabled ?? false
      softDeletePolicyStatusEnabled: item.?softDeletePolicyStatusEnabled ?? false
      softDeletePolicyDays: item.?softDeletePolicyDays ?? 7
      trustedServicesBypassEnabled: item.?trustedServicesBypassEnabled ?? true
      zoneRedundancyEnabled: item.?zoneRedundancyEnabled ?? false
      anonymousPullEnabled: item.?anonymousPullEnabled ?? false
      lock: item.?lock
    }
  }
]

// Outputs
@description('Log Analytics Workspace.')
output log ResourceItem = {
  name: enableLogWorkspace ? log.outputs.name : ''
  id: enableLogWorkspace ? log.outputs.id : ''
}

@description('Storage Accounts.')
output storage ResourceItem[] = [
  for (item, index) in (enableStorage ? storage_items : []): {
    name: storage[index].outputs.name
    id: storage[index].outputs.id
  }
]

@description('Container Registries.')
output containerRegistry ResourceItem[] = [
  for (item, index) in (enableContainerRegistry ? containerRegistry_items : []): {
    name: containerRegistry[index].outputs.name
    id: containerRegistry[index].outputs.id
  }
]

// User Defined Types

//LAW
@description('Features of the workspace.')
type workspaceFeaturesType = {
  @description('Optional. Disable Non-EntraID based Auth. Default is true.')
  disableLocalAuth: bool?
  @description('Optional. Enable logging access using only resource permissions. Default is true.')
  enableLogAccessUsingOnlyResourcePermissions: bool?
}

//Storage
type StoragePrivateEndpointGroupName = 'blob' | 'file' | 'table' | 'queue' | 'dfs'

type ContainerType = {
  @minLength(3)
  @maxLength(63)
  name: string
}

type fileShareType = {
  @minLength(3)
  @maxLength(63)
  name: string
}

type networkAclsType = {
  @description('Optional. Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging, Metrics, AzureServices, or None.')
  bypass: ('Logging' | 'Metrics' | 'AzureServices' | 'Logging, Metrics' | 'Logging, AzureServices')?

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

type StorageConfiguration = {
  @description('Name of Storage Account. Must be unique within Azure.')
  @minLength(3)
  @maxLength(24)
  name: string
  @description('Whether or not to allow shared key access.')
  allowSharedKeyAccess: bool?
  @description('Enable Hierarchical Namespace (Azure Data Lake Storage v2). This cannot be changed once set to true.')
  hierarchicalNamespaceEnabled: bool?
  @description('If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.')
  nfsV3Enabled: bool?
  @description('Enable Secure File Transfer Protocol. This can be enabled only on hierarchicalnamespace enabled stg accounts.')
  sftpEnabled: bool?
  @description('Storage SKU to use: https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types .')
  sku: (
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_LRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'Standard_ZRS')?
  @description('Storage account type (usually should be StorageV2 except in more special cases).')
  kind: ('BlobStorage' | 'BlockBlobStorage' | 'FileStorage' | 'Storage' | 'StorageV2')?
  @description('Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.')
  accessTier: ('Hot' | 'Cool' | 'Cold' | 'Premium')?
  @description('Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet.')
  allowedCopyScope: ('PrivateLink' | 'AAD')?
  @description('Optional. Set to false to skip private endpoint creation for this storage account. Default is true.')
  enablePrivateEndpoints: bool?
  @description('Create the specified private endpoints for the storage account. By default, will create endpoints for `blob`, and if you enable Hierarchical Namespaces, it will create `dfs` as well. Be careful to avoid adding duplicates, it will likely cause the deployment to fail, but won\'t tell you at compile time (yet).')
  privateEndpointGroupNames: StoragePrivateEndpointGroupName[]?
  @minValue(1)
  @maxValue(365)
  @description('Indicates the number of days that the deleted item should be retained. The minimum specified value can be 1 and the maximum value can be 365.')
  deleteRetentionPolicyDays: int?
  @description('Blob Containers to create with the storage account')
  containers: ContainerType[]?
  @description('The Storage Account ManagementPolicies Rules.')
  managementPolicyRules: array?
  @description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
  tags: object?
  @description('Resource ID for the log workspace if adding diagnostic settings')
  diagnosticLogWorkspaceId: string?
  @description('Optional. The blob service properties for blob soft delete.')
  deleteRetentionPolicyEnabled: bool?
  @description('Optional array of file shares to create in the storage accounts')
  fileShares: fileShareType[]?
  @description('Optional. This property when set to true allows deletion of the soft deleted containers.')
  allowContainerPermanentDelete: bool?
  @minValue(1)
  @maxValue(365)
  @description('Optional. Indicates the number of days that the deleted containers should be retained.')
  containerDeleteRetentionPolicyDays: int?
  @description('Optional. The blob service properties for container soft delete. Indicates whether DeleteRetentionPolicy is enabled.')
  containerDeleteRetentionPolicy: bool?
  @description('Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny.')
  networkAcls: networkAclsType?
  @description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.')
  publicNetworkAccess: ('Enabled' | 'Disabled')?
  @description('Optional. Use versioning to automatically maintain previous versions of your blobs. Cannot be enabled for ADLS Gen2 storage accounts(hierarchicalNamespaceEnabled set to true).')
  isVersioningEnabled: bool?
}

//Container Registry
type ContainerRegistryConfiguration = {
  @description('Short name used to generate the full ACR name. Provide only the suffix (e.g. "01" or "acr01"). Full ACR name = toLower("contreg" + replace(environmentName, "-", "") + replace(name, "-", "") + shortName). Example: environmentName="BMRTEST", name="data01", shortName="acr01" -> contregbmrtestdata01acr01')
  @minLength(5)
  @maxLength(50)
  shortName: string
  @description('The SKU of the container registry.')
  skuName: ('Basic' | 'Standard' | 'Premium')?
  @description('Optional. Enable admin user that have push / pull permission to the registry. Default value is False')
  adminUserEnabled: bool?
  @description('Optional. The value that indicates whether the quarantine policy is enabled or not. Note, requires the \'acrSku\' to be \'Premium\'. Default value is False')
  quarantinePolicyStatusEnabled: bool?
  @description('Optional. The value that indicates whether the retention policy is enabled or not.  Default value is False')
  retentionPolicyStatusEnabled: bool?
  @description('Optional. The number of days to retain an untagged manifest after which it gets purged.  Default value is 7')
  retentionPolicyDays: int?
  @description('Optional. The value that indicates whether the export policy is enabled or not.  Default value is False')
  exportPolicyStatusEnabled: bool?
  @description('Optional. Soft Delete policy status. Default value is False.')
  softDeletePolicyStatusEnabled: bool?
  @description('Optional. The number of days after which a soft-deleted item is permanently deleted. Default value is 7')
  softDeletePolicyDays: int?
  @description('Optional. Whether to allow trusted Azure services to access a network restricted registry. Default value is true')
  trustedServicesBypassEnabled: bool?
  @description('Optional. Whether or not zone redundancy is enabled for this container registry. Default value is false')
  zoneRedundancyEnabled: bool?
  @description('Optional. Enables registry-wide pull from unauthenticated clients. It\'s in preview and available in the Standard and Premium service tiers. . Default value is false')
  anonymousPullEnabled: bool?
  @description('Optional. The lock settings of the service.')
  lock: object?
  @description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
  tags: object?
}

type ResourceItem = {
  name: string
  id: string
}
