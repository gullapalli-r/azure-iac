# Azure Container Registries (ACR)

Construct for using an Azure Container Registries with private endpoint

## Details

This construct deploys an Azure Container Registry (ACR) using the most common patterns and options with Private endpoint connectivity .

## Parameters

| Name                            | Type            | Required | Description                                                                                                                                                                                                                                                                                                                                     |
| :------------------------------ | :-------------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                      | `string`        | No       | The Geo-location where the resource lives.                                                                                                                                                                                                                                                                                                      |
| `name`                          | `string`        | Yes      | Name of the resource.                                                                                                                                                                                                                                                                                                                           |
| `tags`                          | `object`        | No       | Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters. |
| `skuName`                       | `string`        | No       | The name of the SKU, Tier of Azure container registry.                                                                                                                                                                                                                                                                                          |
| `adminUserEnabled`              | `bool`          | No       | Enable admin user that have push / pull permission to the registry.                                                                                                                                                                                                                                                                             |
| `quarantinePolicyStatusEnabled` | `bool`          | No       | The value that indicates whether the quarantine policy is enabled or not.                                                                                                                                                                                                                                                                       |
| `retentionPolicyStatusEnabled`  | `bool`          | No       | The value that indicates whether the retention policy is enabled or not. Default is disabled.                                                                                                                                                                                                                                                   |
| `retentionPolicyDays`           | `int`           | No       | The number of days to retain an untagged manifest after which it gets purged.                                                                                                                                                                                                                                                                   |
| `exportPolicyStatusEnabled`     | `bool`          | No       | The value that indicates whether the export policy is enabled or not. Default is disabled.                                                                                                                                                                                                                                                      |
| `softDeletePolicyStatusEnabled` | `bool`          | No       | Soft Delete policy status. Default is disabled.                                                                                                                                                                                                                                                                                                 |
| `softDeletePolicyDays`          | `int`           | No       | The number of days after which a soft-deleted item is permanently deleted.                                                                                                                                                                                                                                                                      |
| `trustedServicesBypassEnabled`  | `bool`          | No       | Whether to allow trusted Azure services to access a network restricted registry.                                                                                                                                                                                                                                                                |
| `zoneRedundancyEnabled`         | `bool`          | No       | Whether or not zone redundancy is enabled for this container registry. Default is disabled.                                                                                                                                                                                                                                                     |
| `anonymousPullEnabled`          | `bool`          | No       | Enables registry-wide pull from unauthenticated clients.                                                                                                                                                                                                                                                                                        |
| `subnetId`                      | `string`        | Yes      | The ID of the subnet from which the private IP will be allocated.                                                                                                                                                                                                                                                                               |
| `lock`                          | `null | object` | No       | Lock configuration for the service.                                                                                                                                                                                                                                                                                                             |

## Outputs

| Name   | Type     | Description                  |
| :----- | :------: | :--------------------------- |
| `id`   | `string` | Identifier for the resource. |
| `name` | `string` | Name of the resource.        |

## Examples

### Example 1

```bicep

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
    tags: {}
    subnetId: subnetId
    anonymousPullEnabled: true
    adminUserEnabled: false
    exportPolicyStatus: 'disabled'
  }
}
```