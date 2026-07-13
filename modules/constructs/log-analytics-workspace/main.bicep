metadata name = 'Log Analytics Workspace'
metadata description = 'Construct for Log Analytics Workspace'
metadata owner = 'Gullapalli-R'

targetScope = 'resourceGroup'

@description('The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('The resource name.')
@minLength(4)
@maxLength(63)
param name string

@description('The name of the SKU.')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerGB2018'

@description('Optional. The workspace features.')
param features workspaceFeaturesType?

@description('The network access type for accessing Log Analytics ingestion.')
param publicNetworkAccessForIngestionEnabled bool = false

@description('The network access type for accessing Log Analytics query.')
param publicNetworkAccessForQueryEnabled bool = false

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('The workspace daily quota for ingestion. Default value is 24.')
@minValue(-1)
param dailyQuotaGb int = 24

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    features: {
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: features.?enableLogAccessUsingOnlyResourcePermissions ?? false
      disableLocalAuth: features.?disableLocalAuth ?? true
      enableDataExport: features.?enableDataExport ?? false
      immediatePurgeDataOn30Days: features.?immediatePurgeDataOn30Days ?? false
    }
    sku: {
      name: sku
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestionEnabled ? 'Enabled' : 'Disabled'
    publicNetworkAccessForQuery: publicNetworkAccessForQueryEnabled ? 'Enabled' : 'Disabled'
  }
}

@description('Identifier for the resource.')
output id string = logWorkspace.id

@description('Name of the resource.')
output name string = logWorkspace.name

@description('Features of the workspace.')
type workspaceFeaturesType = {
  @description('Optional. Disable Non-EntraID based Auth. Default is true.')
  disableLocalAuth: bool?

  @description('Optional. Flag that indicate if data should be exported.')
  enableDataExport: bool?

  @description('Optional. Enable log access using only resource permissions. Default is false.')
  enableLogAccessUsingOnlyResourcePermissions: bool?

  @description('Optional. Flag that describes if we want to remove the data after 30 days.')
  immediatePurgeDataOn30Days: bool?
}
