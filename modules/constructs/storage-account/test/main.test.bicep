/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

@description('Deployment Location')
param location string = resourceGroup().location

@description('Name of Storage Account. Must be unique within Azure.')
@minLength(3)
@maxLength(24)
param name string

@description('Name of the resource group of the vnet')
param vnetResourceGroupName string
@description('Name of the VNET')
param vnetName string
@description('Name of the subnet to host the private links')
param vnetSubnetName string

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('Name of the law id.')
param diagnosticLogWorkspaceId string

var subnetId = resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)

module storage_hns '../main.bicep' = {
  name: '${deployment().name}-stg'
  params: {
    location: location
    name: name
    tags: tags
    subnetId: subnetId
    sku: 'Standard_LRS'
    accessTier: 'Hot'
    allowedCopyScope: 'AAD'
    hierarchicalNamespaceEnabled: false
    nfsV3Enabled: false
    sftpEnabled: false
    publicNetworkAccess: 'Enabled'
    containerDeleteRetentionPolicy: true
    diagnosticLogWorkspaceId: diagnosticLogWorkspaceId
    privateEndpointGroupNames: [
      'blob'
      'dfs'
    ]
    containers: [
      {
        name: 'testcontainer1'
      }
      {
        name: 'testcontainer2'
      }
    ]
  }
}
