@description('Container App name')
param name string

@description('Environment name (e.g., dev, prod) used for tagging')
param environmentName string = 'prod'

@description('Location')
param location string

@description('Resource tags')
param tags object = {}

@description('ACR name for managed identity access')
param containerRegistryName string

@description('ACR login server')
param containerRegistryLoginServer string

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('Full container image name')
param imageName string

resource environment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${name}-env'
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspaceId, '2023-09-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2023-09-01').primarySharedKey
      }
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': 'web-${environmentName}', environment: environmentName })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: environment.id
    workloadProfileName: 'Consumption'
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        transport: 'auto'
      }
      registries: [
        {
          server: containerRegistryLoginServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'hackathon'
          image: imageName
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}

// Grant ACR pull permission to the container app's managed identity
// Uses a fixed name derived from resource IDs for idempotency
@description('Whether to create the ACR pull role assignment (set false if it already exists)')
param createAcrPullRole bool = true

resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (createAcrPullRole) {
  name: guid(acr.id, containerApp.id, '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  scope: acr
  properties: {
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
