@description('ACR name (must be globally unique, alphanumeric only)')
param name string

@description('Location')
param location string

@description('Resource tags')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output name string = acr.name
output loginServer string = acr.properties.loginServer
