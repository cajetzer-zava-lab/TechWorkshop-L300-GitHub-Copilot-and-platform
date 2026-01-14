# Copilot Instructions for ZavaStorefront

**Repository**: https://github.com/cajetzer-zava-lab/TechWorkshop-L300-GitHub-Copilot-and-platform

## Project Overview

ZavaStorefront is an ASP.NET Core MVC e-commerce application (.NET 6) deployed to Azure using containerization. The project uses Azure Developer CLI (azd) and GitHub Actions for deployment.

## Architecture

```
src/                     # .NET 6 MVC application
├── Controllers/         # HomeController (products), CartController (cart ops)
├── Services/           # Business logic (ProductService, CartService)
├── Models/             # Domain models (Product, CartItem)
├── Views/              # Razor views with Bootstrap 5
infra/                  # Bicep IaC templates
├── main.bicep          # Orchestrator (subscription-scope deployment)
├── modules/            # Modular resources (ACR, App Service, AI Foundry)
```

**Key design notes of current state:**
- **No database**: Products are hardcoded in `ProductService`; cart uses session storage via `CartService`
- **Dependency injection**: Services registered in `Program.cs` (`ProductService` as singleton, `CartService` as scoped)
- **Container deployment**: Builds in ACR (no local Docker required) via `az acr build`

## Developer Workflows

### Run Locally
```bash
cd src
dotnet run
# Browse to https://localhost:5001
```

### Deploy to Azure (recommended)
```bash
azd up                    # Provision infra + deploy app
azd provision             # Infra only
azd deploy                # App only (builds container in ACR)
```

### GitHub Actions
Push to `main` branch triggers build and deploy. Required GitHub variables: `ACR_NAME`, `WEBAPP_NAME`, `RESOURCE_GROUP`.

## Code Patterns & Conventions

### Adding New Features

**New Controller**: Follow pattern in [HomeController.cs](src/Controllers/HomeController.cs) - inject `ILogger<T>` and services via constructor:
```csharp
public MyController(ILogger<MyController> logger, ProductService productService, CartService cartService)
```

**New Service**: Register in [Program.cs](src/Program.cs):
- Use `AddSingleton<T>()` for stateless services
- Use `AddScoped<T>()` for services needing `IHttpContextAccessor` (session access)

**New Bicep Module**: Create in `infra/modules/`, reference from `main.bicep` with explicit `scope: rg`

### Session-Based Cart Pattern
Cart operations in `CartService` serialize to JSON in session storage. Always use the service methods (`AddToCart`, `RemoveFromCart`, `UpdateQuantity`) - never access session directly in controllers.

### Logging Convention
Use structured logging with named parameters:
```csharp
_logger.LogInformation("Adding product {ProductId} ({ProductName}) to cart", productId, product.Name);
```

## Infrastructure Notes

- **Subscription-scope deployment**: `main.bicep` creates resource group, then deploys modules into it
- **Naming convention**: `{type}-{baseName}-{env}[-{uniqueSuffix}]` (e.g., `app-zavastore-dev-abc123`)
- **AI Foundry**: Pre-configured for GPT-4 and Phi-3 model deployments
- **Managed Identity**: Web App uses system-assigned identity with AcrPull role

## Tool Preferences

When MCP Server tools are available, prefer them over CLI commands:
- **GitHub operations**: Use `mcp_github-remote_*` tools instead of `gh` CLI when applicable
- **Azure operations**: Use Azure MCP tools (when available) over `az` CLI when applicable

This reduces context switching, improves reliability, and provides structured responses.

## Do NOT

- Add database dependencies without discussion - this is intentionally stateless
- Modify product data outside `ProductService._products`
- Deploy infrastructure changes without testing with `azd provision` first
- Store secrets in code - use GitHub secrets or Azure Key Vault
