#!/bin/bash
set -euo pipefail

RESOURCE_GROUP="${1:-rg-ghcp-hackathon}"
LOCATION="${2:-eastus2}"
ACR_NAME="${3:-ghcphackathonacr}"
IMAGE_TAG="${4:-latest}"

echo "=== Creating resource group ==="
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "=== Deploying infrastructure ==="
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file infra/main.bicep \
  --parameters baseName=ghcp-hackathon imageTag="$IMAGE_TAG"

echo "=== Getting ACR login server ==="
ACR_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)

echo "=== Building and pushing Docker image ==="
az acr login --name "$ACR_NAME"
docker build -t "$ACR_SERVER/hackathon:$IMAGE_TAG" .
docker push "$ACR_SERVER/hackathon:$IMAGE_TAG"

echo "=== Updating container app ==="
APP_NAME="ghcp-hackathon-app"
az containerapp update \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "$ACR_SERVER/hackathon:$IMAGE_TAG"

echo "=== Deployment complete ==="
APP_URL=$(az containerapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" -o tsv)
echo "Site available at: https://$APP_URL"
