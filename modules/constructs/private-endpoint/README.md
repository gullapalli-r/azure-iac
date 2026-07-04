# Private Endpoint

Private Endpoint used for accessing private resources on internal networks

## Details

{{Add detailed information about the module}}

## Parameters

| Name                           | Type     | Required | Description                                                                                                                                                                                                                                                                                                                                     |
| :----------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                         | `string` | Yes      | The resource name.                                                                                                                                                                                                                                                                                                                              |
| `location`                     | `string` | Yes      | The Geo-location where the resource lives.                                                                                                                                                                                                                                                                                                      |
| `subnetId`                     | `string` | Yes      | The ID of the subnet from which the private IP will be allocated.                                                                                                                                                                                                                                                                               |
| `serviceId`                    | `string` | Yes      | The resource id of private link service (the service being linked privately).                                                                                                                                                                                                                                                                   |
| `tags`                         | `object` | No       | Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters. |
| `endpointGroupId`              | `string` | Yes      | The ID of the group obtained from the remote resource that this private endpoint should connect to (https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview).                                                                                                                                                            |
| `requiresManualApproval`       | `bool`   | No       | Whether or not manual approval for a Private Endpoint connection is required.                                                                                                                                                                                                                                                                   |
| `manualApprovalRequestMessage` | `string` | No       | Message to pass on when requesting manual endpoint approval workflow.                                                                                                                                                                                                                                                                           |

## Outputs

| Name   | Type     | Description           |
| :----- | :------: | :-------------------- |
| `id`   | `string` | ID of the resource.   |
| `name` | `string` | Name of the resource. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```