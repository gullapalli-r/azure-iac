metadata name = 'Azure Container Registries (ACR)'
metadata description = 'Construct for using an Azure Container Registries with private endpoint'
metadata owner = 'Gullapalli-R'

@description('The Geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Name of the resource.')
@minLength(5)
@maxLength(50)
param name string

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('The name of the SKU, Tier of Azure container registry.')
@allowed([
  'Basic'
  'Premium'
  'Standard'
])
param skuName string = 'Premium'

@description('Enable admin user that have push / pull permission to the registry.')
param adminUserEnabled bool = false

@description('The value that indicates whether the quarantine policy is enabled or not.')
param quarantinePolicyStatusEnabled bool = false

@description('The value that indicates whether the retention policy is enabled or not. Default is disabled.')
param retentionPolicyStatusEnabled bool = false

@description('The number of days to retain an untagged manifest after which it gets purged.')
@minValue(1)
@maxValue(365)
param retentionPolicyDays int = 7

@description('The value that indicates whether the export policy is enabled or not. Default is disabled.')
param exportPolicyStatusEnabled bool = false

@description('Soft Delete policy status. Default is disabled.')
param softDeletePolicyStatusEnabled bool = false

@description('The number of days after which a soft-deleted item is permanently deleted.')
@minValue(1)
@maxValue(90)
param softDeletePolicyDays int = 7

@description('Whether to allow trusted Azure services to access a network restricted registry.')
param trustedServicesBypassEnabled bool = true

@description('Whether or not zone redundancy is enabled for this container registry. Default is disabled.')
param zoneRedundancyEnabled bool = false

@description('Enables registry-wide pull from unauthenticated clients.')
param anonymousPullEnabled bool = true

@description('The ID of the subnet from which the private IP will be allocated.')
param subnetId string

@description('Lock configuration for the service.')
param lock LockType?

resource registry 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: []
    }
    policies: {
      quarantinePolicy: {
        status: quarantinePolicyStatusEnabled ? 'enabled' : 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: retentionPolicyDays
        status: retentionPolicyStatusEnabled ? 'enabled' : 'disabled'
      }
      exportPolicy: {
        status: exportPolicyStatusEnabled ? 'enabled' : 'disabled'
      }
      azureADAuthenticationAsArmPolicy: {
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: softDeletePolicyDays
        status: softDeletePolicyStatusEnabled ? 'enabled' : 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleBypassOptions: trustedServicesBypassEnabled ? 'AzureServices' : 'None'
    zoneRedundancy: zoneRedundancyEnabled ? 'Enabled' : 'Disabled'
    anonymousPullEnabled: anonymousPullEnabled
  }

  resource scope_admin 'scopeMaps' = {
    name: '_repositories_admin'
    properties: {
      description: 'Can perform all read, write and delete operations on the registry'
      actions: [
        'repositories/*/metadata/read'
        'repositories/*/metadata/write'
        'repositories/*/content/read'
        'repositories/*/content/write'
        'repositories/*/content/delete'
      ]
    }
  }

  resource scope_pull 'scopeMaps' = {
    name: '_repositories_pull'
    properties: {
      description: 'Can pull any repository of the registry'
      actions: [
        'repositories/*/content/read'
      ]
    }
  }

  resource scope_push 'scopeMaps' = {
    name: '_repositories_push'
    properties: {
      description: 'Can push to any repository of the registry'
      actions: [
        'repositories/*/content/read'
        'repositories/*/content/write'
      ]
    }
  }
}

resource registry_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.'
  }
  scope: registry
}

var groupId = 'registry'

module privateEndpoint 'br:bicepiacregistry.azurecr.io/bicep/constructs/private-endpoint:0.1.1' = if (!empty(subnetId)) {
  name: '${deployment().name}-PE'
  params: {
    endpointGroupId: groupId
    location: location
    name: '${name}-${groupId}-PE'
    serviceId: registry.id
    subnetId: subnetId
    tags: tags
  }
}

@description('Identifier for the resource.')
output id string = registry.id

@description('Name of the resource.')
output name string = registry.name

type LockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}
