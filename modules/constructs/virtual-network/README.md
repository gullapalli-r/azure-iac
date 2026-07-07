# Virtual Networks

This module deploys a Virtual Network (vNet).

## Details

{{Add detailed information about the module}}

graph LR
A[stamp/main.bicep\ntargetScope: subscription] -->|creates| B[Resource Group]
B -->|scope| C[constructs/virtual-network\nmain.bicep\ntargetScope: resourceGroup]
C -->|1 first| D[modules/network-security-group.bicep\n→ outputs resourceId]
C -->|2 second| E[modules/route-table.bicep\n→ outputs resourceId]
C -->|3 last, uses IDs from D+E| F[VNet + Subnets]

## Parameters

| Name                                | Type            | Required | Description                                                                                                                                                                                                                                                                                                                      |
| :---------------------------------- | :-------------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                              | `string`        | Yes      | Required. The name of the Virtual Network (vNet).                                                                                                                                                                                                                                                                                |
| `location`                          | `string`        | No       | Optional. Location for all resources.                                                                                                                                                                                                                                                                                            |
| `addressPrefixes`                   | `array`         | Yes      | Required. An Array of 1 or more IP Address Prefixes OR the resource ID of the IPAM pool to be used for the Virtual Network. When specifying an IPAM pool resource ID you must also set a value for the parameter called `ipamPoolNumberOfIpAddresses`.                                                                           |
| `ipamPoolNumberOfIpAddresses`       | `null | string` | No       | Optional. Number of IP addresses allocated from the pool. To be used only when the addressPrefix param is defined with a resource ID of an IPAM pool.                                                                                                                                                                            |
| `virtualNetworkBgpCommunity`        | `null | string` | No       | Optional. The BGP community associated with the virtual network.                                                                                                                                                                                                                                                                 |
| `subnets`                           | `null | array`  | No       | Optional. An Array of subnets to deploy to the Virtual Network.                                                                                                                                                                                                                                                                  |
| `dnsServers`                        | `null | array`  | No       | Optional. DNS Servers associated to the Virtual Network.                                                                                                                                                                                                                                                                         |
| `ddosProtectionPlanResourceId`      | `null | string` | No       | Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it's left blank, DDoS protection will not be configured. If it's provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription. |
| `peerings`                          | `null | array`  | No       | Optional. Virtual Network Peering configurations.                                                                                                                                                                                                                                                                                |
| `vnetEncryption`                    | `bool`          | No       | Optional. Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet. Requires the EnableVNetEncryption feature to be registered for the subscription and a supported region to use this property.                                                                          |
| `vnetEncryptionEnforcement`         | `string`        | No       | Optional. If the encrypted VNet allows VM that does not support encryption. Can only be used when vnetEncryption is enabled.                                                                                                                                                                                                     |
| `flowTimeoutInMinutes`              | `int`           | No       | Optional. The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. Default value 0 will set the property to null.                                                                                                      |
| `diagnosticSettings`                | `null | array`  | No       | Optional. The diagnostic settings of the service.                                                                                                                                                                                                                                                                                |
| `lock`                              | `null | object` | No       | Optional. The lock settings of the service.                                                                                                                                                                                                                                                                                      |
| `roleAssignments`                   | `null | array`  | No       | Optional. Array of role assignments to create.                                                                                                                                                                                                                                                                                   |
| `tags`                              | `null | object` | No       | Optional. Tags of the resource.                                                                                                                                                                                                                                                                                                  |
| `enableVmProtection`                | `bool | null`   | No       | Optional. Indicates if VM protection is enabled for all the subnets in the virtual network.                                                                                                                                                                                                                                      |
| `enablePrivateEndpointVNetPolicies` | `string`        | No       | Optional. Enables high scale private endpoints for the virtual network. This is necessary if the virtual network requires more than 1000 private endpoints or is peered to virtual networks with a total of more than 4000 private endpoints.                                                                                    |
| `ipAllocations`                     | `null | array`  | No       | Optional. Array of IpAllocation which reference this VNET.                                                                                                                                                                                                                                                                       |
| `networkSecurityGroups`             | `null | array`  | No       | Optional. Array of Network Security Groups to create and associate to subnets.                                                                                                                                                                                                                                                   |
| `routeTables`                       | `null | array`  | No       | Optional. Array of Route Tables to create and associate to subnets.                                                                                                                                                                                                                                                              |

## Outputs

| Name                | Type     | Description                                               |
| :------------------ | :------: | :-------------------------------------------------------- |
| `resourceGroupName` | `string` | The resource group the virtual network was deployed into. |
| `resourceId`        | `string` | The resource ID of the virtual network.                   |
| `name`              | `string` | The name of the virtual network.                          |
| `subnetNames`       | `array`  | The names of the deployed subnets.                        |
| `subnetResourceIds` | `array`  | The resource IDs of the deployed subnets.                 |
| `location`          | `string` | The location the resource was deployed into.              |
| `nsgItems`          | `array`  | The deployed Network Security Groups.                     |
| `routeTableItems`   | `array`  | The deployed Route Tables.                                |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```