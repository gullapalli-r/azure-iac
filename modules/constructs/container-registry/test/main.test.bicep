/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

@description('The Geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Name of the resource')
@minLength(5)
@maxLength(50)
param name string

@description('Name of the resource group of the vnet')
param vnetResourceGroupName string
@description('Name of the VNET')
param vnetName string
@description('Name of the subnet to host the private links')
param vnetSubnetName string

var subnetId = resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)

module registry '../main.bicep' = {
  name: '${deployment().name}-ACR'
  params: {
    location: location
    name: name
    tags: {
      BRMTEST: 'Test'
    }
    subnetId: subnetId
    anonymousPullEnabled: true
    adminUserEnabled: false
    exportPolicyStatusEnabled: false
    //lock: {
    //  kind: 'CanNotDelete'
    //  name: 'ACR-Lock'
    //}
  }
}
