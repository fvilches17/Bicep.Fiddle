param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: 'bicepfiddle-asp'
  location: location
  kind: 'linux'
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}
