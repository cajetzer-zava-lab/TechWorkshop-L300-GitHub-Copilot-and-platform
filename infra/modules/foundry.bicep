// Azure AI Foundry module (formerly Azure AI Hub)
// Provides access to GPT-4 and Phi models

@description('Name of the AI Foundry account')
param name string

@description('Location for resources')
param location string = resourceGroup().location

@description('SKU for the AI Foundry resource')
param sku string = 'S0'

@description('Tags for resources')
param tags object = {}

resource aiFoundry 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: name
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: sku
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// GPT-4o model deployment (gpt-4o available in westus3 with Standard SKU)
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: aiFoundry
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
    raiPolicyName: 'Microsoft.Default'
  }
}

// Phi-4-mini-reasoning model deployment (Microsoft format, GlobalStandard SKU)
resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: aiFoundry
  name: 'phi-4-mini-reasoning'
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4-mini-reasoning'
      version: '1'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  dependsOn: [
    gpt4Deployment
  ]
}

@description('The resource ID of the AI Foundry account')
output id string = aiFoundry.id

@description('The endpoint URL for the AI Foundry account')
output endpoint string = aiFoundry.properties.endpoint

@description('The name of the AI Foundry account')
output name string = aiFoundry.name
