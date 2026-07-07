targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string

@description('Required. The name of the Virtual Network (vNet).')
param vNetName string

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// ============== //
// Test Execution //
// ============== //

var addressPrefix = '10.0.0.0/16'
@batchSize(1)
module testDeployment '../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${iteration}'
    params: {
      name: vNetName
      addressPrefixes: [
        addressPrefix
      ]
      dnsServers: [
        '10.0.1.4'
        '10.0.1.5'
      ]
      networkSecurityGroups: [
        {
          name: 'SNET-IaC-EastUS-Test-PrivateLink-NSG'
          securityRules: [] // add rules as needed
        }
        {
          name: 'SNET-IaC-EastUS-Test-AppsVM-NSG'
          securityRules: []
        }
      ]
      routeTables: [
        {
          name: 'SNET-IaC-EastUS-Test-PrivateLink-Route'
          routes: [] // add routes as needed
        }
        {
          name: 'SNET-IaC-EastUS-Test-AppsVM-Route'
          routes: []
        }
      ]
      subnets: [
        {
          addressPrefix: cidrSubnet(addressPrefix, 24, 0)
          name: 'SNET-IaC-EastUS-Test-PrivateLink'
          networkSecurityGroupName: 'SNET-IaC-EastUS-Test-PrivateLink-NSG'
          routeTableName: 'SNET-IaC-EastUS-Test-PrivateLink-Route'
        }
        {
          addressPrefix: cidrSubnet(addressPrefix, 24, 1)
          name: 'SNET-IaC-EastUS-Test-AppsVM'
          networkSecurityGroupName: 'SNET-IaC-EastUS-Test-AppsVM-NSG'
          routeTableName: 'SNET-IaC-EastUS-Test-AppsVM-Route'
        }
      ]
      peerings: [
        {
          name: 'PN_SPOKE-IaC-EastUS-Test-01-Spoke'
          remoteVirtualNetworkResourceId: '/subscriptions/4c324251-b16a-4681-b57e-19eea5661e88/resourceGroups/rg-hub-eastus/providers/Microsoft.Network/virtualNetworks/HUB-USEast'
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: false
          allowGatewayTransit: false
          useRemoteGateways: false
          doNotVerifyRemoteGateways: false
          enableOnlyIPv6Peering: false
        }
      ]
    }
  }
]
