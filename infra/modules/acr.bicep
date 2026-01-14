// Azure Container Registry module
// Provides container image storage with Basic SKU for dev environment

@description('Name of the Azure Container Registry')
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('SKU for the container registry')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Basic'

@description('Tags for resources')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

@description('The resource ID of the container registry')
output id string = acr.id

@description('The name of the container registry')
output name string = acr.name

@description('The login server URL of the container registry')
output loginServer string = acr.properties.loginServer
