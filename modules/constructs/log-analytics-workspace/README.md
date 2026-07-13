# Log Analytics Workspace

Construct for Log Analytics Workspace

## Details

This module deploys an Azure Log Analytics Workspace designed with enterprise security and operational monitoring as core principles. The workspace is preconfigured with security-first defaults to align with organizational compliance requirements while maintaining flexibility for different deployment scenarios.

### Security Architecture

The workspace is deployed with a System-Assigned Managed Identity, eliminating the need for managing credentials and enabling seamless integration with Azure RBAC for authentication and authorization. By default, local authentication is disabled, enforcing the use of Microsoft Entra ID as the sole authentication mechanism. This ensures all access attempts are tracked through Entra ID audit logs and comply with zero-trust security models. Public network access for both ingestion and query operations is disabled by default, requiring you to explicitly enable it only when necessary or to use Private Endpoints for a fully private networking topology.

### Flexibility and Scale

The module supports multiple SKU options to accommodate different cost and performance requirements. The default `PerGB2018` SKU is suitable for most deployments with pay-as-you-go pricing, while `CapacityReservation` is recommended for predictable, high-volume workloads. The daily ingestion quota can be configured to control costs, with a default of 24 GB per day. Setting the quota to -1 removes the limit entirely, allowing unlimited ingestion.

### Advanced Features and Compliance

Optional workspace features enable additional capabilities such as data export functionality for integration with external systems, immediate data purge after 30 days for regulatory compliance, and resource-permissions-only access mode which restricts log access to users with explicit RBAC permissions on the monitored resource. These features can be selectively enabled based on organizational policy and compliance mandates.

### Enterprise Tagging

The workspace supports comprehensive tagging for cost allocation and resource governance across resource groups and subscriptions. Tags enable you to track monitoring costs per team, environment, or application, facilitating chargeback and optimization.

### Best Practices Included

This module follows Azure Well-Architected Framework recommendations by defaulting to secure configurations. Local authentication is disabled, restricting access to Entra ID-authenticated principals. Public network access is disabled by default, encouraging private endpoint adoption for production workloads. The workspace is designed to serve as a centralized monitoring and analytics hub for VNets, applications, and infrastructure across your environment.

## Parameters

| Name                                     | Type            | Required | Description                                                                                                                                                                                                                                                                                                                                     |
| :--------------------------------------- | :-------------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                               | `string`        | No       | The geo-location where the resource lives.                                                                                                                                                                                                                                                                                                      |
| `name`                                   | `string`        | Yes      | The resource name.                                                                                                                                                                                                                                                                                                                              |
| `sku`                                    | `string`        | No       | The name of the SKU.                                                                                                                                                                                                                                                                                                                            |
| `features`                               | `null | object` | No       | Optional. The workspace features.                                                                                                                                                                                                                                                                                                               |
| `publicNetworkAccessForIngestionEnabled` | `bool`          | No       | The network access type for accessing Log Analytics ingestion.                                                                                                                                                                                                                                                                                  |
| `publicNetworkAccessForQueryEnabled`     | `bool`          | No       | The network access type for accessing Log Analytics query.                                                                                                                                                                                                                                                                                      |
| `tags`                                   | `object`        | No       | Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters. |
| `dailyQuotaGb`                           | `int`           | No       | The workspace daily quota for ingestion. Default value is 24.                                                                                                                                                                                                                                                                                   |

## Outputs

| Name   | Type     | Description                  |
| :----- | :------: | :--------------------------- |
| `id`   | `string` | Identifier for the resource. |
| `name` | `string` | Name of the resource.        |

## Examples

### Example 1

```bicep

/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

@description('Deployment Location')
param location string = resourceGroup().location

@description('The resource name.')
@minLength(4)
@maxLength(63)
param name string

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object

@description('Optional. The workspace daily quota for ingestion.')
@minValue(-1)
param dailyQuotaGb int = 24

module logWorkspace '../main.bicep' = {
  name: '${deployment().name}-LOG'
  params: {
    location: location
    name: name
    tags:tags
    dailyQuotaGb: dailyQuotaGb
    features:{
      disableLocalAuth:true
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

```

### Example 2

```bicep
```