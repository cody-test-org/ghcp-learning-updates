#!/bin/bash
# =============================================================================
# bootstrap.sh — One-time infrastructure setup for the GHCP Hackathon site
#
# This script creates the Azure resource group and deploys the Bicep
# infrastructure (Container Apps environment, ACR, Log Analytics, etc.).
# Run it once to stand up the environment; after that, all application
# builds and deployments are handled by the CI/CD pipeline.
#
# Usage:
#   ./infra/bootstrap.sh [RESOURCE_GROUP] [LOCATION]
#
# Examples:
#   ./infra/bootstrap.sh                          # uses defaults
#   ./infra/bootstrap.sh rg-my-group westus2      # custom values
# =============================================================================
set -euo pipefail

RESOURCE_GROUP="${1:-rg-ghcp-hackathon}"
LOCATION="${2:-eastus2}"

echo "=== One-time infrastructure bootstrap ==="
echo "Resource Group : $RESOURCE_GROUP"
echo "Location       : $LOCATION"
echo ""

# --- Create resource group ---------------------------------------------------
echo "=== Creating resource group ==="
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

# --- Deploy Bicep infrastructure ---------------------------------------------
echo "=== Deploying Bicep infrastructure (infra/main.bicep) ==="
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file infra/main.bicep \
  --parameters \
    baseName=ghcp-hackathon \
    imageTag=latest \
    environments="['dev','prod']"

# --- Print deployment outputs ------------------------------------------------
echo ""
echo "=== Deployment outputs ==="
az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name main \
  --query properties.outputs \
  --output table

echo ""
echo "=== Bootstrap complete ==="
echo "NOTE: Ongoing application builds and deployments are handled by the"
echo "      CI/CD pipeline (GitHub Actions). You should not need to run"
echo "      this script again unless you are recreating the infrastructure."
