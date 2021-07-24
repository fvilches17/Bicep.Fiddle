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

resource webAppKeyVaultRoleBasedAccess 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: '9311cb4a-2f20-49a2-af4a-aba81f1097fc'
  scope: keyVault
  properties: {
    principalId: webApp.identity.principalId
    roleDefinitionId: 'Key Vault Secrets User'
  }
  dependsOn: [
    keyVault
  ]
}

