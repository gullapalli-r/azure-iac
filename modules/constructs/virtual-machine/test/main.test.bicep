@description('Deployment Location')
param location string = resourceGroup().location

@description('Name of Storage Account. Must be unique within Azure.')
@minLength(3)
@maxLength(24)
param windowsvmName string
//param linuxvmName string

@description('Name of the resource group of the vnet')
param vnetResourceGroupName string
@description('Name of the VNET')
param vnetName string
@description('Name of the subnet to host the private links')
param vnetSubnetName string

var subnetId = resourceId(vnetResourceGroupName, 'Microsoft.Network/virtualNetworks/subnets', vnetName, vnetSubnetName)

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

//@description('Name of the Key Vault to fetch secrets from')
//param keyVaultName string = ''

//resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
//  name: keyVaultName
//}

module windowsVM '../main.bicep' = {
  name: '${deployment().name}-vm'
  params: {
    adminUsername: 'bhadmin'
    publicNetworkAccess: 'Enabled'
    osType: 'Windows'
    location: location
    name: windowsvmName
    subnetId: subnetId
    extensionAadJoinConfig: {
      enabled: false
    }
    managedIdentities: {
      systemAssigned: true
    }
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-datacenter-gensecond'
      version: 'latest'
    }
    tags: tags
    vmSize: 'Standard_D2ads_v7'
    securityType: ''
    secureBootEnabled: false
    vTpmEnabled: false
    osDisk: {
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'StandardSSD_LRS'
      }
    }
    adminPassword: 'Password@1234!'
    ipallocation: 'Dynamic'
  }
}
