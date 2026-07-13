metadata name = 'Private Endpoint'
metadata description = 'Private Endpoint used for accessing private resources on POC internal networks'
metadata owner = 'Gullapalli-R'

targetScope = 'resourceGroup'

@description('The resource name.')
@minLength(2)
@maxLength(64)
param name string

@description('The Geo-location where the resource lives.')
param location string

@description('The ID of the subnet from which the private IP will be allocated.')
param subnetId string

@description('The resource id of private link service (the service being linked privately).')
param serviceId string

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('The ID of the group obtained from the remote resource that this private endpoint should connect to (https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview).')
@allowed([
  'account'
  'amlworkspace'
  'API'
  'application gateway'
  'AzureBackup'
  'azuremonitor'
  'AzureSiteRecovery'
  'batchAccount'
  'blob'
  'blob_secondary'
  'browser_authentication'
  'Cassandra'
  'cluster'
  'configurationStores'
  'coordinator'
  'databricks_ui_api'
  'dataFactory'
  'Dev'
  'dfs'
  'dfs_secondary'
  'domain'
  'DSCAndHybridWorker'
  'empty'
  'eventHub'
  'fhir'
  'file'
  'File Sync Service'
  'file_secondary'
  'Gremlin'
  'Gateway'
  'hosting environment'
  'hybridcompute'
  'HSM'
  'IoTApps'
  'iotDps'
  'iotHub'
  'keydelivery'
  'liveevent'
  'managed disk'
  'management'
  'mariadbServer'
  'MongoDB'
  'mysqlServer'
  'namespace'
  'nodeManagement'
  'portal'
  'postgresqlServer'
  'Power BI'
  'project'
  'queue'
  'queue_secondary'
  'redisCache'
  'redisEnterprise'
  'registry'
  'ResourceManagement'
  'searchService'
  'signalr'
  'sites'
  'sites-slot-dev'
  'sites-slot-qa'
  'sites-slot-testing'
  'sites-slot-staging'
  'sites-slot-preprod'
  'sites-slot-prod'
  'SQL'
  'SqlOnDemand'
  'sqlServer'
  'staticSites'
  'streamingendpoint'
  'Table'
  'table'
  'table_secondary'
  'topic'
  'vault'
  'web'
  'web_secondary'
  'Webhook'
  'webpubsub'
  'grafana'
  'prometheusMetrics'
  'Bot'
  'AzureBackup'
  'AzureSiteRecovery'
  'managedEnvironments'
])
param endpointGroupId string

@description('Whether or not manual approval for a Private Endpoint connection is required.')
param requiresManualApproval bool = false

@description('Message to pass on when requesting manual endpoint approval workflow.')
@maxLength(140)
param manualApprovalRequestMessage string = ''

var privateLinkServiceConnection = {
  name: name
  properties: {
    privateLinkServiceId: serviceId
    groupIds: [
      endpointGroupId
    ]
    requestMessage: requiresManualApproval ? manualApprovalRequestMessage : null
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    manualPrivateLinkServiceConnections: requiresManualApproval ? [ privateLinkServiceConnection ] : []
    privateLinkServiceConnections: requiresManualApproval ? [] : [ privateLinkServiceConnection ]
    customNetworkInterfaceName: '${name}-NIC'

  }
}

@description('ID of the resource.')
output id string = privateEndpoint.id

@description('Name of the resource.')
output name string = privateEndpoint.name
