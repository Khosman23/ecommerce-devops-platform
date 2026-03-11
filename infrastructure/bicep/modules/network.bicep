param location string
param vnetName string
param addressPrefix string = '10.0.0.0/8'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'aks-subnet'
        properties: {
          addressPrefix: '10.240.0.0/16'
        }
      }
      {
        name: 'services-subnet'
        properties: {
          addressPrefix: '10.0.0.0/16'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output aksSubnetId string = vnet.properties.subnets[0].id