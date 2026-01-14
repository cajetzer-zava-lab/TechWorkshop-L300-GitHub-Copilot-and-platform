# ZavaStorefront Azure Infrastructure

This folder contains Bicep templates for provisioning Azure resources for the ZavaStorefront web application.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Resource Group (westus3)                         │
│                    rg-zavastore-dev-westus3                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────────┐    │
│  │    ACR       │────▶│  App Service │────▶│  App Insights    │    │
│  │   (Basic)    │     │  (Linux B1)  │     │  + Log Analytics │    │
│  └──────────────┘     └──────────────┘     └──────────────────┘    │
│         │                    │                                      │
│         │    AcrPull Role    │                                      │
│         └────────────────────┘                                      │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Azure AI Foundry                           │  │
│  │              (GPT-4 + Phi-4-mini-reasoning deployments)        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Resources

| Resource | Type | SKU | Purpose |
|----------|------|-----|---------|
| ACR | Container Registry | Basic | Store container images |
| App Service Plan | Linux | B1 | Host web application |
| App Service | Web App for Containers | - | Run application container |
| Application Insights | Monitoring | Pay-as-you-go | Application monitoring |
| Log Analytics | Workspace | PerGB2018 | Log storage |
| Azure AI Foundry | Cognitive Services | S0 | AI model access (GPT-4, Phi-4-mini-reasoning) |

## Modules

- [acr.bicep](modules/acr.bicep) - Azure Container Registry
- [appServicePlan.bicep](modules/appServicePlan.bicep) - Linux App Service Plan
- [appService.bicep](modules/appService.bicep) - Web App for Containers
- [appInsights.bicep](modules/appInsights.bicep) - Application Insights + Log Analytics
- [foundry.bicep](modules/foundry.bicep) - Azure AI Foundry with model deployments
- [roleAssignment.bicep](modules/roleAssignment.bicep) - AcrPull role assignment

## Deployment

### Using Azure Developer CLI (azd)

```bash
# Initialize environment
azd init

# Provision infrastructure and deploy
azd up

# Or separately:
azd provision  # Infrastructure only
azd deploy     # Application only
```

### Using Azure CLI

```bash
# Login to Azure
az login

# Deploy at subscription scope
az deployment sub create \
  --location westus3 \
  --template-file main.bicep \
  --parameters environmentName=dev location=westus3
```

### Using GitHub Actions

Push to `main` or `dev` branch, or use workflow dispatch to trigger deployment.

Required secrets:
- `AZURE_CLIENT_ID` - Service principal client ID
- `AZURE_TENANT_ID` - Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID

## Cost Estimates (Dev Environment)

| Resource | Estimated Monthly Cost |
|----------|----------------------|
| ACR Basic | ~$5 |
| App Service B1 | ~$13 |
| Application Insights | Pay per GB ingested |
| Log Analytics | Pay per GB ingested |
| AI Foundry | Pay per 1K tokens |
| **Total (base)** | **~$20/month** |

## Security Features

- ✅ System-assigned managed identity for App Service
- ✅ RBAC-based ACR pull (no password secrets)
- ✅ HTTPS only
- ✅ TLS 1.2 minimum
- ✅ FTPS disabled
- ✅ Non-root container user
