# Azure OIDC Setup for GitHub Actions CI/CD

This document describes the Azure AD and GitHub configuration that enables **passwordless (OIDC) authentication** between GitHub Actions and Azure for the Docker CI/CD pipeline.

## Architecture: Two Service Principals

We use **two separate Azure AD App Registrations** — one for dev, one for production — to enforce least-privilege access:

| Service Principal | App ID | Purpose |
|---|---|---|
| `ghcp-hackathon-ci-dev` | `e8b0fe79-fb7b-46cb-98f3-4449cecb372c` | Build, push images, deploy to **dev** Container App |
| `ghcp-hackathon-ci-prod` | `db9dbeae-12be-4441-948c-692e205d91bb` | Deploy to **production** Container App only |

### Why two SPs?

- **Blast-radius isolation**: A compromised dev workflow cannot touch production resources.
- **Least privilege**: The dev SP can push images (`AcrPush`); the prod SP cannot — it only updates the Container App, which pulls images via its own managed identity.
- **Audit trail**: Separate identities make it clear which environment triggered an Azure action.

## What Was Created

### 1. Azure AD App Registrations

Each app registration has a **federated identity credential** that trusts GitHub's OIDC token issuer for a specific environment:

| App Registration | Federated Credential Subject |
|---|---|
| `ghcp-hackathon-ci-dev` | `repo:cody-test-org/ghcp-learning-updates:environment:dev` |
| `ghcp-hackathon-ci-prod` | `repo:cody-test-org/ghcp-learning-updates:environment:production` |

**Common settings for both:**
- **Issuer**: `https://token.actions.githubusercontent.com`
- **Audience**: `api://AzureADTokenExchange`

### 2. Azure Role Assignments

| Service Principal | Role | Scope |
|---|---|---|
| `ghcp-hackathon-ci-dev` | `AcrPush` | ACR `ghcphackathonacr` |
| `ghcp-hackathon-ci-dev` | `Contributor` | Resource Group `rg-ghcp-hackathon` |
| `ghcp-hackathon-ci-prod` | `Contributor` | Resource Group `rg-ghcp-hackathon` |

> **Note**: The prod SP does **not** have `AcrPush` — the Container App's managed identity handles ACR pull. The prod SP only needs permission to update the Container App resource.

### 3. GitHub Environments

Two environments are configured on the repository `cody-test-org/ghcp-learning-updates`:

#### Environment: `dev`

**Secrets:**
| Secret | Value |
|---|---|
| `AZURE_CLIENT_ID` | `e8b0fe79-fb7b-46cb-98f3-4449cecb372c` |
| `AZURE_TENANT_ID` | `2fe0eed0-5684-4f79-b2ed-25f1b8df8371` |
| `AZURE_SUBSCRIPTION_ID` | `2a1b501e-d398-4fb5-8680-01acff08b7d2` |

**Variables:**
| Variable | Value |
|---|---|
| `ACR_NAME` | `ghcphackathonacr` |
| `ACR_LOGIN_SERVER` | `ghcphackathonacr.azurecr.io` |
| `RESOURCE_GROUP` | `rg-ghcp-hackathon` |
| `CONTAINER_APP_NAME` | `ghcp-hackathon-dev-app` |

#### Environment: `production`

**Secrets:**
| Secret | Value |
|---|---|
| `AZURE_CLIENT_ID` | `db9dbeae-12be-4441-948c-692e205d91bb` |
| `AZURE_TENANT_ID` | `2fe0eed0-5684-4f79-b2ed-25f1b8df8371` |
| `AZURE_SUBSCRIPTION_ID` | `2a1b501e-d398-4fb5-8680-01acff08b7d2` |

**Variables:**
| Variable | Value |
|---|---|
| `ACR_NAME` | `ghcphackathonacr` |
| `ACR_LOGIN_SERVER` | `ghcphackathonacr.azurecr.io` |
| `RESOURCE_GROUP` | `rg-ghcp-hackathon` |
| `CONTAINER_APP_NAME` | `ghcp-hackathon-prod-app` |

> **Manual step**: Consider adding **required reviewers** as a protection rule on the `production` environment via the GitHub UI at:
> `Settings → Environments → production → Required reviewers`

## How OIDC Works in the Workflow

The GitHub Actions workflow uses `azure/login@v2` with OIDC:

```yaml
permissions:
  id-token: write   # Required for OIDC token request
  contents: read

jobs:
  deploy:
    environment: dev  # or production
    steps:
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

GitHub mints a short-lived OIDC token scoped to the environment. Azure validates the token against the federated credential's issuer, subject, and audience — no stored secrets needed.

## How to Rotate or Update Credentials

Since OIDC uses federated credentials (no client secrets), there is **nothing to rotate** for normal operation. If you need to change the setup:

### Change the GitHub repository or organization

Update the federated credential subject:

```bash
# Delete old credential
az ad app federated-credential delete --id <app-object-id> --federated-credential-id <cred-id>

# Create new one with updated subject
az ad app federated-credential create --id <app-object-id> --parameters '{
  "name": "github-actions-dev",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:NEW-ORG/NEW-REPO:environment:dev",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

### Revoke access

```bash
# Delete the service principal (disables all access immediately)
az ad sp delete --id <sp-object-id>

# Or just remove role assignments
az role assignment delete --assignee <app-id> --role "Contributor" --scope <scope>
```

## How to Narrow Role Assignments After First Deployment

The current `Contributor` role on the resource group is broader than necessary. After the Container Apps are created by the first Bicep deployment, narrow the scope:

```bash
# Remove broad RG-level Contributor
az role assignment delete \
  --assignee "e8b0fe79-fb7b-46cb-98f3-4449cecb372c" \
  --role "Contributor" \
  --scope "/subscriptions/2a1b501e-d398-4fb5-8680-01acff08b7d2/resourceGroups/rg-ghcp-hackathon"

# Add scoped role on just the dev Container App
az role assignment create \
  --assignee "e8b0fe79-fb7b-46cb-98f3-4449cecb372c" \
  --role "Contributor" \
  --scope "/subscriptions/2a1b501e-d398-4fb5-8680-01acff08b7d2/resourceGroups/rg-ghcp-hackathon/providers/Microsoft.App/containerApps/ghcp-hackathon-dev-app"

# Same for prod SP on the prod Container App
az role assignment delete \
  --assignee "db9dbeae-12be-4441-948c-692e205d91bb" \
  --role "Contributor" \
  --scope "/subscriptions/2a1b501e-d398-4fb5-8680-01acff08b7d2/resourceGroups/rg-ghcp-hackathon"

az role assignment create \
  --assignee "db9dbeae-12be-4441-948c-692e205d91bb" \
  --role "Contributor" \
  --scope "/subscriptions/2a1b501e-d398-4fb5-8680-01acff08b7d2/resourceGroups/rg-ghcp-hackathon/providers/Microsoft.App/containerApps/ghcp-hackathon-prod-app"
```

## Troubleshooting

### `AADSTS700024: Client assertion is not within its valid time range`

- The GitHub runner's clock may be skewed. This is rare with GitHub-hosted runners.
- Ensure the `id-token: write` permission is set in the workflow.

### `AADSTS70021: No matching federated identity record found`

- The federated credential **subject** must match exactly. Check:
  - Repository name (case-sensitive): `cody-test-org/ghcp-learning-updates`
  - Environment name: `dev` or `production` (must match the GitHub environment name exactly)
  - The workflow job must reference the correct `environment:` value.

### `AuthorizationFailed: does not have authorization to perform action`

- The SP is missing a role assignment. Check current assignments:
  ```bash
  az role assignment list --assignee <app-id> --all -o table
  ```

### `Login failed: Azure CLI not found` or OIDC errors

- Ensure the workflow uses `azure/login@v2` (not v1).
- Ensure `permissions.id-token: write` is set at the job or workflow level.

### Verify the full setup

```bash
# List federated credentials
az ad app federated-credential list --id <app-object-id> -o table

# List role assignments
az role assignment list --assignee <app-id> --all -o table

# List GitHub environment secrets (names only)
gh secret list --env dev
gh secret list --env production
```
