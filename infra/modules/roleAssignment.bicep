// Role Assignment module
// Assigns AcrPull role to Web App managed identity for ACR access

@description('Principal ID of the managed identity')
param principalId string

@description('Resource ID of the Azure Container Registry')
param acrId string

@description('Principal type')
@allowed(['ServicePrincipal', 'User', 'Group'])
param principalType string = 'ServicePrincipal'

// AcrPull role definition ID
var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// Reference to existing ACR for scoping
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: last(split(acrId, '/'))
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrId, principalId, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: principalId
    principalType: principalType
  }
}

@description('The role assignment ID')
output roleAssignmentId string = acrPullRoleAssignment.id
