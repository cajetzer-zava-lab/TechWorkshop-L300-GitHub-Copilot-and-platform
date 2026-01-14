// Application Insights module
// Provides monitoring and diagnostics with Log Analytics workspace

@description('Name of the Application Insights resource')
param name string

@description('Name of the Log Analytics workspace')
param logAnalyticsName string

@description('Location for resources')
param location string = resourceGroup().location

@description('Tags for resources')
param tags object = {}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The resource ID of Application Insights')
output id string = appInsights.id

@description('The instrumentation key for Application Insights')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('The connection string for Application Insights')
output connectionString string = appInsights.properties.ConnectionString

@description('The resource ID of Log Analytics workspace')
output logAnalyticsId string = logAnalytics.id
