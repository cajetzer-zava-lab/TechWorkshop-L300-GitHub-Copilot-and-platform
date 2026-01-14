// Main Bicep template for ZavaStorefront infrastructure
// Orchestrates all Azure resources for the dev environment
targetScope = 'subscription'

@description('Environment name (dev, staging, prod)')
@allowed(['dev', 'staging', 'prod'])
param environmentName string = 'dev'

@description('Location for all resources')
param location string = 'westus3'

@description('Base name for resources')
param baseName string = 'zavastore'

@description('Container image tag')
param imageTag string = 'latest'

@description('App Service Plan SKU')
param appServicePlanSku string = 'B1'

@description('ACR SKU')
param acrSku string = 'Basic'

// Generate resource names
var resourceGroupName = 'rg-${baseName}-${environmentName}-${location}'
var uniqueSuffix = uniqueString(subscription().subscriptionId, baseName, environmentName)
var acrName = replace('acr${baseName}${environmentName}${take(uniqueSuffix, 6)}', '-', '')
var appServicePlanName = 'asp-${baseName}-${environmentName}'
var webAppName = 'app-${baseName}-${environmentName}-${take(uniqueSuffix, 6)}'
var appInsightsName = 'ai-${baseName}-${environmentName}'
var logAnalyticsName = 'log-${baseName}-${environmentName}'
var aiFoundryName = 'aif-${baseName}-${environmentName}'

var tags = {
  environment: environmentName
  application: baseName
  'azd-env-name': environmentName
  SecurityControl: 'Ignore'
  CostControl: 'Ignore'
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Azure Container Registry
module acr 'modules/acr.bicep' = {
  scope: rg
  name: 'acr-deployment'
  params: {
    name: acrName
    location: location
    sku: acrSku
    tags: tags
  }
}

// Application Insights and Log Analytics
module appInsights 'modules/appInsights.bicep' = {
  scope: rg
  name: 'appinsights-deployment'
  params: {
    name: appInsightsName
    logAnalyticsName: logAnalyticsName
    location: location
    tags: tags
  }
}

// App Service Plan
module appServicePlan 'modules/appServicePlan.bicep' = {
  scope: rg
  name: 'appserviceplan-deployment'
  params: {
    name: appServicePlanName
    location: location
    skuName: appServicePlanSku
    tags: tags
  }
}

// Web App for Containers
module webApp 'modules/appService.bicep' = {
  scope: rg
  name: 'webapp-deployment'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    acrLoginServer: acr.outputs.loginServer
    containerImage: '${baseName}:${imageTag}'
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    tags: tags
  }
}

// Role Assignment - AcrPull for Web App managed identity
module roleAssignment 'modules/roleAssignment.bicep' = {
  scope: rg
  name: 'roleassignment-deployment'
  params: {
    principalId: webApp.outputs.principalId
    acrId: acr.outputs.id
  }
}

// Azure AI Foundry
module aiFoundry 'modules/foundry.bicep' = {
  scope: rg
  name: 'aifoundry-deployment'
  params: {
    name: aiFoundryName
    location: location
    tags: tags
  }
}

// Outputs
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_APP_SERVICE_NAME string = webApp.outputs.name
output AZURE_APP_SERVICE_URL string = 'https://${webApp.outputs.defaultHostname}'
output AZURE_APPLICATION_INSIGHTS_NAME string = appInsightsName
output AZURE_AI_FOUNDRY_NAME string = aiFoundry.outputs.name
output AZURE_AI_FOUNDRY_ENDPOINT string = aiFoundry.outputs.endpoint
