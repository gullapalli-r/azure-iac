metadata name = 'Virtual Networks'
metadata description = 'This module deploys a Virtual Network (vNet).'
metadata owner = 'Gullapalli-R'

@description('Required. The name of the Virtual Network (vNet).')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes OR the resource ID of the IPAM pool to be used for the Virtual Network. When specifying an IPAM pool resource ID you must also set a value for the parameter called `ipamPoolNumberOfIpAddresses`.')
param addressPrefixes string[]

@description('Optional. Number of IP addresses allocated from the pool. To be used only when the addressPrefix param is defined with a resource ID of an IPAM pool.')
param ipamPoolNumberOfIpAddresses string?

@description('Optional. The BGP community associated with the virtual network.')
param virtualNetworkBgpCommunity string?

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets subnetType[]?

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers string[]?

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanResourceId string?

@description('Optional. Virtual Network Peering configurations.')
param peerings peeringType[]?

@description('Optional. Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet. Requires the EnableVNetEncryption feature to be registered for the subscription and a supported region to use this property.')
param vnetEncryption bool = false

@allowed([
  'AllowUnencrypted'
  'DropUnencrypted'
])
@description('Optional. If the encrypted VNet allows VM that does not support encryption. Can only be used when vnetEncryption is enabled.')
param vnetEncryptionEnforcement string = 'AllowUnencrypted'

@maxValue(30)
@description('Optional. The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. Default value 0 will set the property to null.')
param flowTimeoutInMinutes int = 0

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingFullType[]?

@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

@description('Optional. Tags of the resource.')
//param tags resourceInput<'Microsoft.Network/virtualNetworks@2025-05-01'>.tags?
param tags object?

//@description('Optional. Enable/Disable usage telemetry for module.')
//param enableTelemetry bool = true

@description('Optional. Indicates if VM protection is enabled for all the subnets in the virtual network.')
param enableVmProtection bool?

@allowed([
  'Basic'
  'Disabled'
])
@description('Optional. Enables high scale private endpoints for the virtual network. This is necessary if the virtual network requires more than 1000 private endpoints or is peered to virtual networks with a total of more than 4000 private endpoints.')
param enablePrivateEndpointVNetPolicies string = 'Disabled'

@description('Optional. Array of IpAllocation which reference this VNET.')
//param ipAllocations resourceInput<'Microsoft.Network/virtualNetworks@2025-05-01'>.properties.ipAllocations?
param ipAllocations object[]?

//var enableReferencedModulesTelemetry = false

//var builtInRoleNames = {
//  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
//  'Network Contributor': subscriptionResourceId(
//    'Microsoft.Authorization/roleDefinitions',
//    '4d97b98b-1d4f-4787-a291-c67834d212e7'
//  )
//  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
//  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
//  'Role Based Access Control Administrator': subscriptionResourceId(
//    'Microsoft.Authorization/roleDefinitions',
//    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
//  )
//  'User Access Administrator': subscriptionResourceId(
//    'Microsoft.Authorization/roleDefinitions',
//    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
//  )
//}
//
//var formattedRoleAssignments = [
//  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
//    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
//        roleAssignment.roleDefinitionIdOrName,
//        '/providers/Microsoft.Authorization/roleDefinitions/'
//      )
//      ? roleAssignment.roleDefinitionIdOrName
//      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
//  })
//]

@description('Optional. Array of Network Security Groups to create and associate to subnets.')
param networkSecurityGroups NsgConfiguration[]?

@description('Optional. Array of Route Tables to create and associate to subnets.')
param routeTables RouteTableConfiguration[]?

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipAllocations: ipAllocations
    addressSpace: contains(addressPrefixes[0], '/Microsoft.Network/networkManagers/')
      ? {
          ipamPoolPrefixAllocations: [
            {
              pool: {
                id: addressPrefixes[0]
              }
              numberOfIpAddresses: ipamPoolNumberOfIpAddresses
            }
          ]
        }
      : {
          addressPrefixes: addressPrefixes
        }
    bgpCommunities: !empty(virtualNetworkBgpCommunity)
      ? {
          virtualNetworkCommunity: virtualNetworkBgpCommunity!
        }
      : null
    ddosProtectionPlan: !empty(ddosProtectionPlanResourceId)
      ? {
          id: ddosProtectionPlanResourceId
        }
      : null
    dhcpOptions: !empty(dnsServers)
      ? {
          dnsServers: array(dnsServers)
        }
      : null
    enableDdosProtection: !empty(ddosProtectionPlanResourceId)
    encryption: vnetEncryption == true
      ? {
          enabled: vnetEncryption
          enforcement: vnetEncryptionEnforcement
        }
      : null
    flowTimeoutInMinutes: flowTimeoutInMinutes != 0 ? flowTimeoutInMinutes : null
    enableVmProtection: enableVmProtection
    privateEndpointVNetPolicies: enablePrivateEndpointVNetPolicies
  }
}

module subnet_nsgs 'modules/network-security-group.bicep' = [
  for (nsg, index) in (networkSecurityGroups ?? []): {
    name: '${uniqueString(subscription().id, resourceGroup().id, location)}-nsg-${index}'
    params: {
      name: nsg.name
      securityRules: nsg.?securityRules
      tags: nsg.?tags ?? tags
    }
  }
]

module subnet_rts 'modules/route-table.bicep' = [
  for (rt, index) in (routeTables ?? []): {
    name: '${uniqueString(subscription().id, resourceGroup().id, location)}-rt-${index}'
    params: {
      name: rt.name
      routes: rt.?routes
      disableBgpRoutePropagation: rt.?disableBgpRoutePropagation ?? false
      tags: rt.?tags ?? tags
    }
  }
]
@batchSize(1)
module virtualNetwork_subnets 'modules/subnet.bicep' = [
  for (subnet, index) in (subnets ?? []): {
    dependsOn: [
      subnet_nsgs   // ← ensures NSGs exist before subnet association
      subnet_rts    // ← ensures RTs exist before subnet association
    ]
    name: '${uniqueString(subscription().id, resourceGroup().id, location)}-subnet-${index}'
    params: {
      virtualNetworkName: virtualNetwork.name
      name: subnet.name
      addressPrefix: subnet.?addressPrefix
      addressPrefixes: subnet.?addressPrefixes
      ipamPoolPrefixAllocations: subnet.?ipamPoolPrefixAllocations
      applicationGatewayIPConfigurations: subnet.?applicationGatewayIPConfigurations
      delegation: subnet.?delegation
      natGatewayResourceId: subnet.?natGatewayResourceId
      // Resolve NSG: by name (construct-created) OR by resource ID (pre-existing)
      networkSecurityGroupResourceId: subnet.?networkSecurityGroupName != null
        ? resourceId('Microsoft.Network/networkSecurityGroups', subnet.networkSecurityGroupName!)
        : subnet.?networkSecurityGroupResourceId
      routeTableResourceId: subnet.?routeTableName != null
        ? resourceId('Microsoft.Network/routeTables', subnet.routeTableName!)
        : subnet.?routeTableResourceId
      privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: subnet.?privateLinkServiceNetworkPolicies
      serviceEndpointPolicies: subnet.?serviceEndpointPolicies
      serviceEndpoints: subnet.?serviceEndpoints ?? []
      defaultOutboundAccess: subnet.?defaultOutboundAccess
      sharingScope: subnet.?sharingScope
      ipAllocations: subnet.?ipAllocations
      serviceGateway: subnet.?serviceGateway
    }
  }
]

// Local to Remote peering
module virtualNetwork_peering_local 'modules/virtual-network-peering.bicep' = [
  for (peering, index) in (peerings ?? []): {
    name: '${uniqueString(subscription().id, resourceGroup().id, location)}-virtualNetworkPeering-local-${index}'
    // This is a workaround for an error in which the peering is deployed whilst the subnet creation is still taking place
    // TODO: https://github.com/Azure/bicep/issues/1013 would be a better solution
    dependsOn: [
      virtualNetwork_subnets
    ]
    params: {
      localVnetName: virtualNetwork.name
      remoteVirtualNetworkResourceId: peering.remoteVirtualNetworkResourceId
      name: peering.?name
      allowForwardedTraffic: peering.?allowForwardedTraffic
      allowGatewayTransit: peering.?allowGatewayTransit
      allowVirtualNetworkAccess: peering.?allowVirtualNetworkAccess
      doNotVerifyRemoteGateways: peering.?doNotVerifyRemoteGateways
      useRemoteGateways: peering.?useRemoteGateways
      enableOnlyIPv6Peering: peering.?enableOnlyIPv6Peering
      //enableTelemetry: enableReferencedModulesTelemetry
    }
  }
]

// Remote to local peering (reverse)
module virtualNetwork_peering_remote 'modules/virtual-network-peering.bicep' = [
  for (peering, index) in (peerings ?? []): if (peering.?remotePeeringEnabled ?? false) {
    name: '${uniqueString(subscription().id, resourceGroup().id, location)}-virtualNetworkPeering-remote-${index}'
    // This is a workaround for an error in which the peering is deployed whilst the subnet creation is still taking place
    // TODO: https://github.com/Azure/bicep/issues/1013 would be a better solution
    dependsOn: [
      virtualNetwork_subnets
    ]
    scope: resourceGroup(
      split(peering.remoteVirtualNetworkResourceId, '/')[2],
      split(peering.remoteVirtualNetworkResourceId, '/')[4]
    )
    params: {
      localVnetName: last(split(peering.remoteVirtualNetworkResourceId, '/'))
      remoteVirtualNetworkResourceId: virtualNetwork.id
      name: peering.?remotePeeringName
      allowForwardedTraffic: peering.?remotePeeringAllowForwardedTraffic
      allowGatewayTransit: peering.?remotePeeringAllowGatewayTransit
      allowVirtualNetworkAccess: peering.?remotePeeringAllowVirtualNetworkAccess
      doNotVerifyRemoteGateways: peering.?remotePeeringDoNotVerifyRemoteGateways
      useRemoteGateways: peering.?remotePeeringUseRemoteGateways
      enableOnlyIPv6Peering: peering.?enableOnlyIPv6Peering
      //enableTelemetry: enableReferencedModulesTelemetry
    }
  }
]

resource virtualNetwork_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: virtualNetwork
}

resource virtualNetwork_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? [{ categoryGroup: 'allLogs' }]): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: virtualNetwork
  }
]

//resource virtualNetwork_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
//  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
//    name: roleAssignment.?name ?? guid(virtualNetwork.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
//    properties: {
//      roleDefinitionId: roleAssignment.roleDefinitionId
//      principalId: roleAssignment.principalId
//      description: roleAssignment.?description
//      principalType: roleAssignment.?principalType
//      condition: roleAssignment.?condition
//      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
//      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
//    }
//    scope: virtualNetwork
//  }
//]

@description('The resource group the virtual network was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the virtual network.')
output resourceId string = virtualNetwork.id

@description('The name of the virtual network.')
output name string = virtualNetwork.name

@description('The names of the deployed subnets.')
output subnetNames array = [for (subnet, index) in (subnets ?? []): virtualNetwork_subnets[index].outputs.name]

@description('The resource IDs of the deployed subnets.')
output subnetResourceIds array = [
  for (subnet, index) in (subnets ?? []): virtualNetwork_subnets[index].outputs.resourceId
]

@description('The location the resource was deployed into.')
output location string = virtualNetwork.location

@description('The deployed Network Security Groups.')
output nsgItems ResourceItem[] = [
  for (nsg, index) in (networkSecurityGroups ?? []): {
    name: subnet_nsgs[index].outputs.name
    id: subnet_nsgs[index].outputs.resourceId
  }
]

@description('The deployed Route Tables.')
output routeTableItems ResourceItem[] = [
  for (rt, index) in (routeTables ?? []): {
    name: subnet_rts[index].outputs.name
    id: subnet_rts[index].outputs.resourceId
  }
]

// =============== //
//   Definitions   //
// =============== //

@export()
type peeringType = {
  @description('Optional. The Name of VNET Peering resource. If not provided, default value will be peer-localVnetName-remoteVnetName.')
  name: string?

  @description('Required. The Resource ID of the VNet that is this Local VNet is being peered to. Should be in the format of a Resource ID.')
  remoteVirtualNetworkResourceId: string

  @description('Optional. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. Default is true.')
  allowForwardedTraffic: bool?

  @description('Optional. If gateway links can be used in remote virtual networking to link to this virtual network. Default is false.')
  allowGatewayTransit: bool?

  @description('Optional. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. Default is true.')
  allowVirtualNetworkAccess: bool?

  @description('Optional. Do not verify the provisioning state of the remote gateway. Default is true.')
  doNotVerifyRemoteGateways: bool?

  @description('Optional. If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Default is false.')
  useRemoteGateways: bool?

  @description('Optional. Deploy the outbound and the inbound peering.')
  remotePeeringEnabled: bool?

  @description('Optional. The name of the VNET Peering resource in the remove Virtual Network. If not provided, default value will be peer-remoteVnetName-localVnetName.')
  remotePeeringName: string?

  @description('Optional. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. Default is true.')
  remotePeeringAllowForwardedTraffic: bool?

  @description('Optional. If gateway links can be used in remote virtual networking to link to this virtual network. Default is false.')
  remotePeeringAllowGatewayTransit: bool?

  @description('Optional. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. Default is true.')
  remotePeeringAllowVirtualNetworkAccess: bool?

  @description('Optional. Do not verify the provisioning state of the remote gateway. Default is true.')
  remotePeeringDoNotVerifyRemoteGateways: bool?

  @description('Optional. If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway. Default is false.')
  remotePeeringUseRemoteGateways: bool?

  @description('Optional. Whether only Ipv6 address space is peered for subnet peering.')
  enableOnlyIPv6Peering: bool?
}

type nsgSecurityRuleType = {
  @description('Required. Name of the security rule.')
  name: string
  properties: {
    access: 'Allow' | 'Deny'
    description: string?
    destinationAddressPrefix: string?
    destinationAddressPrefixes: string[]?
    destinationPortRange: string?
    destinationPortRanges: string[]?
    direction: 'Inbound' | 'Outbound'
    priority: int
    protocol: '*' | 'Ah' | 'Esp' | 'Icmp' | 'Tcp' | 'Udp'
    sourceAddressPrefix: string?
    sourceAddressPrefixes: string[]?
    sourcePortRange: string?
    sourcePortRanges: string[]?
  }
}

type NsgConfiguration = {
  @description('Required. Name of the Network Security Group.')
  name: string
  @description('Optional. Security rules to deploy.')
  securityRules: nsgSecurityRuleType[]?
  @description('Optional. Tags. Defaults to VNet tags if not specified.')
  tags: object?
}

type routeEntryType = {
  @description('Required. Name of the route.')
  name: string
  properties: {
    @description('Required. The destination CIDR to which the route applies.')
    addressPrefix: string
    @description('Required. The type of Azure hop the packet should be sent to.')
    nextHopType: 'Internet' | 'None' | 'VirtualAppliance' | 'VirtualNetworkGateway' | 'VnetLocal'
    @description('Optional. The IP address packets should be forwarded to. Only allowed if nextHopType is VirtualAppliance.')
    nextHopIpAddress: string?
    @description('Optional. If true, the route overrides overlapping BGP routes.')
    hasBgpOverride: bool?
  }
}

type RouteTableConfiguration = {
  @description('Required. Name of the Route Table.')
  name: string
  @description('Optional. Routes to deploy.')
  routes: routeEntryType[]?
  @description('Optional. Disable BGP route propagation. Default false.')
  disableBgpRoutePropagation: bool?
  @description('Optional. Tags. Defaults to VNet tags if not specified.')
  tags: object?
}

type ResourceItem = {
  name: string
  id: string
}

@export()
type subnetType = {
  @description('Required. The Name of the subnet resource.')
  name: string

  @description('Conditional. The address prefix for the subnet. Required if `addressPrefixes` is empty.')
  addressPrefix: string?

  @description('Conditional. List of address prefixes for the subnet. Required if `addressPrefix` is empty.')
  addressPrefixes: string[]?

  @description('Conditional. The address space for the subnet, deployed from IPAM Pool. Required if `addressPrefixes` and `addressPrefix` is empty and the VNet address space configured to use IPAM Pool.')
  //ipamPoolPrefixAllocations: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2025-05-01'>.properties.ipamPoolPrefixAllocations?
  ipamPoolPrefixAllocations: object[]?

  @description('Optional. Application gateway IP configurations of virtual network resource.')
  //applicationGatewayIPConfigurations: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2025-05-01'>.properties.applicationGatewayIPConfigurations?
  applicationGatewayIPConfigurations: object[]?

  @description('Optional. The delegation to enable on the subnet.')
  delegation: string?

  @description('Optional. The resource ID of the NAT Gateway to use for the subnet.')
  natGatewayResourceId: string?

  @description('Optional. The resource ID of the network security group to assign to the subnet.')
  networkSecurityGroupResourceId: string?

  @description('Optional. enable or disable apply network policies on private endpoint in the subnet.')
  privateEndpointNetworkPolicies: ('Disabled' | 'Enabled' | 'NetworkSecurityGroupEnabled' | 'RouteTableEnabled')?

  @description('Optional. enable or disable apply network policies on private link service in the subnet.')
  privateLinkServiceNetworkPolicies: ('Disabled' | 'Enabled')?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType[]?

  @description('Optional. The resource ID of the route table to assign to the subnet.')
  routeTableResourceId: string?

  @description('Optional. An array of service endpoint policies.')
  //serviceEndpointPolicies: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2025-05-01'>.properties.serviceEndpointPolicies?
  serviceEndpointPolicies: object[]?

  @description('Optional. The service endpoints to enable on the subnet.')
  serviceEndpoints: string[]?

  @description('Optional. Set this property to false to disable default outbound connectivity for all VMs in the subnet. This property can only be set at the time of subnet creation and cannot be updated for an existing subnet.')
  defaultOutboundAccess: bool?

  @description('Optional. Set this property to Tenant to allow sharing subnet with other subscriptions in your AAD tenant. This property can only be set if defaultOutboundAccess is set to false, both properties can only be set if subnet is empty.')
  sharingScope: ('DelegatedServices' | 'Tenant')?

  @description('Optional. Array of IpAllocation which reference this subnet.')
  //ipAllocations: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2025-05-01'>.properties.ipAllocations?
  ipAllocations: object[]?
  
  @description('Optional. Reference to an existing service gateway.')
  //serviceGateway: resourceInput<'Microsoft.Network/virtualNetworks/subnets@2025-05-01'>.properties.serviceGateway?
  serviceGateway: object?

  @description('Optional. Name of an NSG from the `networkSecurityGroups` param. Construct creates and links it. Mutually exclusive with networkSecurityGroupResourceId.')
  networkSecurityGroupName: string?

  @description('Optional. Name of a Route Table from the `routeTables` param. Construct creates and links it. Mutually exclusive with routeTableResourceId.')
  routeTableName: string?
}

@export()
@description('An AVM-aligned type for a diagnostic setting. To be used if both logs & metrics are supported by the resource provider.')
type diagnosticSettingFullType = {
  @description('Optional. The name of the diagnostic setting.')
  name: string?

  @description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to `[]` to disable log collection.')
  logCategoriesAndGroups: {
    @description('Optional. Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.')
    category: string?

    @description('Optional. Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs.')
    categoryGroup: string?

    @description('Optional. Enable or disable the category explicitly. Default is `true`.')
    enabled: bool?
  }[]?

  @description('Optional. The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.')
  metricCategories: {
    @description('Required. Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
    category: string

    @description('Optional. Enable or disable the category explicitly. Default is `true`.')
    enabled: bool?
  }[]?

  @description('Optional. A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('Optional. The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}

@export()
@description('An AVM-aligned type for a lock.')
type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?

  @description('Optional. Specify the notes of the lock.')
  notes: string?
}

@export()
@description('An AVM-aligned type for a role assignment.')
type roleAssignmentType = {
  @description('Optional. The name (as GUID) of the role assignment. If not provided, a GUID will be generated.')
  name: string?

  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}
