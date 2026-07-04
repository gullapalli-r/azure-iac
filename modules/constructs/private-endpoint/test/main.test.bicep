/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

param location string = resourceGroup().location
param storageName string

@description('Name of the resource group of the vnet')
param vnetResourceGroupName string
@description('Name of the VNET')
param vnetName string
@description('Name of the subnet to host the private links')
param vnetSubnetName string

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object

var subnetId = resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)

module storage 'storage.bicep' = {
  name: '${deployment().name}-ST'
  params: {
    location: location
    name: storageName
    tags:tags
  }
}

module peAutomatic '../main.bicep' = {
  name: '${deployment().name}-PE-Auto'
  params: {
    location: location
    name: '${storageName}-blob-PE'
    tags: tags
    endpointGroupId: 'blob'
    serviceId: storage.outputs.id
    subnetId: subnetId
  }
}
