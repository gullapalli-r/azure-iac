# platform-services

Stamp for platform-services, allowing for multiple required resources.

## Details

{{Add detailed information about the module}}

## Parameters

| Name                                  | Type     | Required | Description                                                                                                                                                                                                                                                                                                                                     |
| :------------------------------------ | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                            | `string` | No       | Geo-location of the resources.                                                                                                                                                                                                                                                                                                                  |
| `environmentName`                     | `string` | Yes      | Name for the environment, this is the container for the application and data stamps and can be like: `np01`, `stg02`, `demo01`. It may not have an index at first, but could later. Keep this short as it is used for generating names. Use DNS segment naming rules.                                                                           |
| `name`                                | `string` | No       | Name for the application stamp, default `app`. This will be used to generate automatic names for resources. If deploying multiple application stamps into an environment, make sure to change this to avoid overwriting resources. Use DNS segment naming rules.                                                                                |
| `vnet_resourceGroup`                  | `string` | Yes      | Name of the resource group of the virtual network.                                                                                                                                                                                                                                                                                              |
| `vnet_name`                           | `string` | Yes      | Name of the virtual network.                                                                                                                                                                                                                                                                                                                    |
| `vnet_privateLinkSubnet`              | `string` | Yes      | Name of the Private Link subnet.                                                                                                                                                                                                                                                                                                                |
| `enableLogWorkspace`                  | `bool`   | No       | Enable Log Workspace.                                                                                                                                                                                                                                                                                                                           |
| `enableStorage`                       | `bool`   | No       | Enable Storage.                                                                                                                                                                                                                                                                                                                                 |
| `enableContainerRegistry`             | `bool`   | No       | Enable Container Registry.                                                                                                                                                                                                                                                                                                                      |
| `tags`                                | `object` | No       | Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters. |
| `dailyQuotaGb`                        | `int`    | No       | The workspace daily quota for ingestion. Default value is 24.                                                                                                                                                                                                                                                                                   |
| `enableLogAnalyticsWorkspaceFeatures` | `object` | No       | Optional. The workspace features.                                                                                                                                                                                                                                                                                                               |
| `storage_items`                       | `array`  | No       | Storage Accounts to deploy.                                                                                                                                                                                                                                                                                                                     |
| `containerRegistry_items`             | `array`  | No       | Container Registries to deploy.                                                                                                                                                                                                                                                                                                                 |

## Outputs

| Name                | Type     | Description              |
| :------------------ | :------: | :----------------------- |
| `log`               | `object` | Log Analytics Workspace. |
| `storage`           | `array`  | Storage Accounts.        |
| `containerRegistry` | `array`  | Container Registries.    |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```