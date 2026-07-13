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
