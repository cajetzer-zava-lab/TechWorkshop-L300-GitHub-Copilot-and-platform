// App Service (Web App for Containers) module
// Linux Web App configured to pull images from ACR using managed identity

@description('Name of the Web App')
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('Resource ID of the App Service Plan')
param appServicePlanId string

@description('ACR login server URL')
param acrLoginServer string

@description('Container image name and tag')
param containerImage string = 'zavastore:latest'

@description('Application Insights instrumentation key')
param appInsightsInstrumentationKey string = ''

@description('Application Insights connection string')
param appInsightsConnectionString string = ''

@description('Tags for resources')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${containerImage}'
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
      ]
    }
  }
}

@description('The resource ID of the Web App')
output id string = webApp.id

@description('The name of the Web App')
output name string = webApp.name

@description('The default hostname of the Web App')
output defaultHostname string = webApp.properties.defaultHostName

@description('The principal ID of the system-assigned managed identity')
output principalId string = webApp.identity.principalId
