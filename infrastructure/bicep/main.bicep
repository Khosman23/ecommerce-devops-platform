targetScope = 'subscription'

param location string = 'westeurope'
param secondaryLocation string = 'eastus'
param environment string = 'prod'
param aksNodeCount int = 2

var prefix = 'ecommerce'
var primaryRgName = '${prefix}-${environment}-we-rg'
var secondaryRgName = '${prefix}-${environment}-eus-rg'
var acrName = '${prefix}${environment}khoacr'
var keyVaultName = '${prefix}-${environment}-kho-kv'

// Primary Resource Group - West Europe
resource primaryRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: primaryRgName
  location: location
}

// Secondary Resource Group - East US
resource secondaryRg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: secondaryRgName
  location: secondaryLocation
}

// Network - Primary Region
module primaryNetwork 'modules/network.bicep' = {
  name: 'primaryNetwork'
  scope: primaryRg
  params: {
    location: location
    vnetName: '${prefix}-${environment}-we-vnet'
  }
}

// Network - Secondary Region
module secondaryNetwork 'modules/network.bicep' = {
  name: 'secondaryNetwork'
  scope: secondaryRg
  params: {
    location: secondaryLocation
    vnetName: '${prefix}-${environment}-eus-vnet'
  }
}

// ACR - Primary Region only (shared across both clusters)
module acr 'modules/acr.bicep' = {
  name: 'acr'
  scope: primaryRg
  params: {
    location: location
    acrName: acrName
  }
}

// Key Vault - Primary Region
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVault'
  scope: primaryRg
  params: {
    location: location
    keyVaultName: keyVaultName
    tenantId: tenant().tenantId
  }
}

// AKS - Primary Region
module primaryAks 'modules/aks.bicep' = {
  name: 'primaryAks'
  scope: primaryRg
  params: {
    location: location
    clusterName: '${prefix}-${environment}-we-aks'
    nodeCount: aksNodeCount
    aksSubnetId: primaryNetwork.outputs.aksSubnetId
    acrId: acr.outputs.acrId
  }
}

// AKS - Secondary Region
module secondaryAks 'modules/aks.bicep' = {
  name: 'secondaryAks'
  scope: secondaryRg
  params: {
    location: secondaryLocation
    clusterName: '${prefix}-${environment}-eus-aks'
    nodeCount: aksNodeCount
    nodeVmSize: 'Standard_DC2ds_v3'
    aksSubnetId: secondaryNetwork.outputs.aksSubnetId
    acrId: acr.outputs.acrId
  }
}

output primaryAksName string = primaryAks.outputs.aksName
output secondaryAksName string = secondaryAks.outputs.aksName
output acrLoginServer string = acr.outputs.acrLoginServer
output keyVaultUri string = keyVault.outputs.keyVaultUri