@description('Application Insights name')
param name string

@description('Location')
param location string

@description('Resource tags')
param tags object = {}

@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string

@description('URL to monitor with availability test')
param availabilityTestUrl string

@description('GitHub repo for workflow dispatch (owner/repo format)')
param githubRepo string = ''

@description('GitHub workflow file name to dispatch')
param githubWorkflowFile string = ''

@description('GitHub PAT for workflow dispatch (from Key Vault or parameter)')
@secure()
param githubDispatchToken string = ''

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    RetentionInDays: 30
  }
}

resource availabilityTest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: '${name}-ping'
  location: location
  tags: union(tags, {
    'hidden-link:${appInsights.id}': 'Resource'
  })
  kind: 'standard'
  properties: {
    SyntheticMonitorId: '${name}-ping'
    Name: '${name} Availability Test'
    Enabled: true
    Frequency: 300
    Timeout: 30
    Kind: 'standard'
    RetryEnabled: true
    Locations: [
      { Id: 'us-va-ash-azr' }
      { Id: 'us-il-ch1-azr' }
      { Id: 'us-ca-sjc-azr' }
    ]
    Request: {
      RequestUrl: availabilityTestUrl
      HttpVerb: 'GET'
      ParseDependentRequests: false
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck: true
      SSLCertRemainingLifetimeCheck: 7
    }
  }
}

// Alert action group — webhook to trigger GitHub workflow_dispatch
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = if (!empty(githubRepo) && !empty(githubDispatchToken)) {
  name: '${name}-dispatch-ag'
  location: 'global'
  tags: tags
  properties: {
    groupShortName: 'ghDispatch'
    enabled: true
    webhookReceivers: [
      {
        name: 'github-workflow-dispatch'
        serviceUri: 'https://api.github.com/repos/${githubRepo}/actions/workflows/${githubWorkflowFile}/dispatches'
        useCommonAlertSchema: false
        useAadAuth: false
      }
    ]
  }
}

// Alert rule — fires when availability test fails 2 consecutive times (~2 min)
resource alertRule 'Microsoft.Insights/metricAlerts@2018-03-01' = if (!empty(githubRepo) && !empty(githubDispatchToken)) {
  name: '${name}-down-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Site availability dropped below 100% — triggers GitHub agentic workflow for investigation and auto-repair'
    severity: 1
    enabled: true
    scopes: [
      appInsights.id
      availabilityTest.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
      webTestId: availabilityTest.id
      componentId: appInsights.id
      failedLocationCount: 2
    }
    actions: [
      {
        actionGroupId: actionGroup.id
        webHookProperties: {
          Authorization: 'Bearer ${githubDispatchToken}'
          ref: 'main'
        }
      }
    ]
  }
}

output appInsightsId string = appInsights.id
output instrumentationKey string = appInsights.properties.InstrumentationKey
output connectionString string = appInsights.properties.ConnectionString
