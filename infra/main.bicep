targetScope = 'resourceGroup'

@description('Name of the azd environment (used as base name for resources)')
param environmentName string = 'ghcp-hackathon'

@description('Base name for all resources (alias for environmentName)')
param baseName string = environmentName

@description('Location for all resources')
param location string = resourceGroup().location

@description('Container image tag')
param imageTag string = 'latest'

@description('Deployment environments sharing ACR and Log Analytics')
param environments array = ['dev', 'prod']

@description('Tags to apply to all resources')
param tags object = {
  CostControl: 'Ignore'
  SecurityControl: 'Ignore'
  'azd-env-name': environmentName
}

@description('GitHub repo for alert-triggered workflow dispatch (owner/repo)')
param githubRepo string = 'cody-test-org/ghcp-learning-updates'

@description('GitHub workflow file to dispatch on alert')
param githubWorkflowFile string = 'site-health-monitor.lock.yml'

@secure()
@description('GitHub PAT with Actions:write scope for workflow dispatch')
param githubDispatchToken string = ''

module acr 'modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    name: replace('${baseName}acr', '-', '')
    location: location
    tags: tags
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    name: '${baseName}-logs'
    location: location
    tags: tags
  }
}

module containerApps 'modules/container-app.bicep' = [for env in environments: {
  name: 'container-app-${env}-deployment'
  params: {
    name: '${baseName}-${env}-app'
    environmentName: env
    location: location
    tags: tags
    containerRegistryName: acr.outputs.name
    containerRegistryLoginServer: acr.outputs.loginServer
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    imageName: '${acr.outputs.loginServer}/hackathon:${imageTag}'
  }
}]

module appInsights 'modules/app-insights.bicep' = {
  name: 'app-insights-deployment'
  params: {
    name: '${baseName}-insights'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    availabilityTestUrl: 'https://${containerApps[length(environments) - 1].outputs.fqdn}'
    githubRepo: githubRepo
    githubWorkflowFile: githubWorkflowFile
    githubDispatchToken: githubDispatchToken
  }
}

output appUrls array = [for (env, i) in environments: {
  environment: env
  fqdn: containerApps[i].outputs.fqdn
}]
// Backward-compatible single URL pointing to the last (prod) environment
output appUrl string = containerApps[length(environments) - 1].outputs.fqdn
output acrLoginServer string = acr.outputs.loginServer
output acrName string = acr.outputs.name
output appInsightsInstrumentationKey string = appInsights.outputs.instrumentationKey

// azd-required outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name
output SERVICE_WEB_ENDPOINT_URL string = 'https://${containerApps[length(environments) - 1].outputs.fqdn}'
