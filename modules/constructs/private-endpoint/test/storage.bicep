targetScope = 'resourceGroup'

@description('Deployment Location')
param location string = resourceGroup().location

@description('Name of Storage Account. Must be unique within Azure.')
@minLength(3)
@maxLength(24)
param name string

@description('Storage SKU to use: https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types')
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

@description('Storage account type (usually should be StorageV2 except in more special cases)')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string = 'StorageV2'

@description('Whether or not to allow shared key access')
param allowSharedKeyAccess bool = false

@description('Whether the default authentication is OAuth or not')
param defaultOAuth bool = true

@description('Enable Hierarchical Namespace (Azure Data Lake Storage v2). This cannot be changed once set to true.')
param hierarchicalNamespaceEnabled bool = false

@description('Source for encryption keys')
@allowed([
  'Microsoft.Storage'
  'Microsoft.KeyVault'
])
param keySource string = 'Microsoft.Storage'

@description('Enable encryption for storage items (cannot be changed after initial deployment)')
param encryptionEnabled bool = true

@description('Require infrastructure encryption (required by policy, cannot be changed after initial deployment)')
param requireInfrastructureEncryption bool = true

@description('Retention policy for soft deletes')
@minValue(1)
@maxValue(365)
param deleteRetentionPolicyDays int = 30

@description('Allow permanent deletion of blobs')
param allowPermanentDelete bool = true

@description('Tags to apply')
param tags object = {}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  tags: tags

  kind: kind
  sku: {
    name:  sku
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultOAuth
    isHnsEnabled: hierarchicalNamespaceEnabled
    encryption: {
      keySource: keySource

      // the following parameters can only be configured at deploy time
      services: {
        blob: {
          enabled: encryptionEnabled
          keyType: 'Account'
        }
        file: {
          enabled: encryptionEnabled
          keyType: 'Account'
        }
        table: {
          enabled: encryptionEnabled
          keyType: 'Account'
        }
        queue: {
          enabled: encryptionEnabled
          keyType: 'Account'
        }
      }
      requireInfrastructureEncryption: requireInfrastructureEncryption
    }
    networkAcls: {
      defaultAction: 'Deny'
    }
  }

  resource blob 'blobServices' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        enabled: true
        days: deleteRetentionPolicyDays
        allowPermanentDelete: allowPermanentDelete
      }
    }
  }
}

@description('Identifier for the storage account')
output id string = storage.id

@description('Name of the storage account')
output name string = storage.name
