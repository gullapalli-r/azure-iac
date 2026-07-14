/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

@description('Environment identifier representing the deployment stage (e.g., dev, stg, prd). Used to categorize and organize resources across different deployment environments. This value is incorporated into resource names for easy identification and tracking.')
param environmentName string = 'dev01'

@description('Workload or service identifier for this platform-services stamp (e.g., infra, core, platform). Used to distinguish multiple platform-services stamps within the same environment. This value is incorporated into resource names to enable multiple deployments without conflicts.')
param name string = 'platform'

@description('Deployment Location')
param location string = resourceGroup().location

// Network Settings
@description('Name of the resource group of the virtual network.')
param vnet_resourceGroup string

@description('Name of the virtual network.')
param vnet_name string

@description('Name of the Private Link subnet.')
param vnet_privateLinkSubnet string

var devTag = {
  'brm.env': 'dev'
}

module data '../main.bicep' = {
  name: '${deployment().name}-INFRA'
  params: {
    location: location
    name: name
    tags: devTag
    environmentName: environmentName
    vnet_name: vnet_name
    vnet_privateLinkSubnet: vnet_privateLinkSubnet
    vnet_resourceGroup: vnet_resourceGroup

    enableLogWorkspace: true
    enableStorage: true
    enableContainerRegistry: true

    storage_items: [
      {
        shortName: 'logs'
        hierarchicalNamespaceEnabled: false
        allowedCopyScope: 'PrivateLink'
        sftpEnabled: false
        accessTier: 'Cool'
        containerDeleteRetentionPolicy: true
        allowContainerPermanentDelete: true
        containerDeleteRetentionPolicyDays: 30
        isVersioningEnabled: true
        deleteRetentionPolicyDays: 2
        fileShares: [
          {
            name: 'filesharetest1'
          }
          {
            name: 'filesharetest2'
          }
        ]
        containers: [
          {
            name: 'testcontainer1'
          }
          {
            name: 'testcontainer2'
          }
        ]
        tags: devTag
      }
      {
        shortName: 'data'
        accessTier: 'Hot'
        hierarchicalNamespaceEnabled: true
        allowedCopyScope: 'PrivateLink'
        sftpEnabled: true
        containerDeleteRetentionPolicy: true
        allowContainerPermanentDelete: true
        containerDeleteRetentionPolicyDays: 30
        isVersioningEnabled: true
        deleteRetentionPolicyDays: 2
        fileShares: [
          {
            name: 'filesharetest1'
          }
          {
            name: 'filesharetest2'
          }
        ]
        containers: [
          {
            name: 'testcontainer1'
          }
          {
            name: 'testcontainer2'
          }
        ]
        tags: devTag
      }
    ]

    containerRegistry_items: [
      {
        shortName: 'acr01'
        skuName: 'Premium'
        adminUserEnabled: false
        quarantinePolicyStatusEnabled: true
        retentionPolicyStatusEnabled: true
        retentionPolicyDays: 30
        exportPolicyStatusEnabled: false
        softDeletePolicyStatusEnabled: true
        softDeletePolicyDays: 30
        trustedServicesBypassEnabled: true
        zoneRedundancyEnabled: false
        anonymousPullEnabled: false
        tags: devTag
      }
    ]
  }
}
