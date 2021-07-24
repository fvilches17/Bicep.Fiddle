@description('Azure Resource Group Location')
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

resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: 'bicepfiddle-blazor-app'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      webSocketsEnabled: true
      http20Enabled: true
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'ASPNETCORE_HTTPS_PORT'
          value: '443'
        }
        {
          name: 'TZ'
          value: 'Pacific/Auckland'
        }
      ]
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: 'bicepfiddle-kv'
  location: location
  properties: {
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = {
  name: '${keyVault.name}/foo'
  properties: {
    value: 'bar'
    contentType: 'string'
  }
}

var KeyVaultsSecretUserRole = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'
resource webAppKeyVaultRoleBasedAccess 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: '4a460d85-2fd0-40a1-839c-582ea160fe9a' //Random unique id
  scope: keyVault
  properties: {
    principalId: webApp.identity.principalId
    roleDefinitionId: KeyVaultsSecretUserRole
  }
  dependsOn: [
    keyVault
  ]
}

output webAppName string = webApp.name
