# GitHub Actions Deployment Setup

This workflow builds the ZavaStorefront .NET application as a container and deploys it to Azure App Service.

## Required GitHub Secrets

Configure the following secret in your repository settings (`Settings > Secrets and variables > Actions > Secrets`):

### `AZURE_CREDENTIALS`
Service principal credentials for Azure authentication in JSON format:

```json
{
  "clientId": "<your-client-id>",
  "clientSecret": "<your-client-secret>",
  "subscriptionId": "<your-subscription-id>",
  "tenantId": "<your-tenant-id>"
}
```

To create the service principal, run:
```bash
az ad sp create-for-rbac \
  --name "github-actions-zavastore" \
  --role contributor \
  --scopes /subscriptions/<your-subscription-id>/resourceGroups/<your-resource-group> \
  --sdk-auth
```

## Required GitHub Variables

Configure the following variables in your repository settings (`Settings > Secrets and variables > Actions > Variables`):

- **`ACR_NAME`**: Name of your Azure Container Registry (e.g., `acrzavastoredewxyz123`)
- **`WEBAPP_NAME`**: Name of your Azure Web App (e.g., `app-zavastore-dev-xyz123`)
- **`RESOURCE_GROUP`**: Name of your Azure Resource Group (e.g., `rg-zavastore-dev-westus3`)

## Additional Permissions

The service principal needs the following permissions:
- **AcrPush** role on the Azure Container Registry
- **Contributor** role on the Resource Group containing the Web App

To assign ACR push permissions:
```bash
az role assignment create \
  --assignee <service-principal-client-id> \
  --role AcrPush \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ContainerRegistry/registries/<acr-name>
```

## Workflow Triggers

The workflow runs automatically on:
- Pushes to the `main` branch
- Manual trigger via the Actions tab (`workflow_dispatch`)

## Deployment Process

1. Checks out the code
2. Authenticates to Azure using service principal
3. Builds the Docker image and pushes to ACR using `az acr build`
4. Updates the Web App container configuration with the new image
5. Restarts the Web App to apply changes
