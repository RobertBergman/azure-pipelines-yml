targetScope = 'resourceGroup'

@description('Azure region to deploy to')
param region string = 'uksouth'

@description('Azure region naming prefix')
param regionNamePrefix string = 'uks'

@description('CIDR block for VWAN Hub')
param vwanHubCIDR string = '10.0.0.0/23'

@description('VWAN Name')
param vwanName string

@description('Tags to apply to applicable resoruces')
param defaultTags object = {
  'IaC-Source': 'jtracey93/PublicScripts'
}

@description('Boolean to decide whether a VPN Gateway is deployed to the VWAN Hub')
param deployVPNGateway bool = false

resource vwanExisting 'Microsoft.Network/virtualWans@2021-02-01' existing = {
  name: vwanName
}

resource vwanHub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: 'vwan-hub-${regionNamePrefix}'
  location: region
  tags: defaultTags
  properties: {
    addressPrefix: vwanHubCIDR
    virtualWan: {
      id: vwanExisting.id
    }
  }
}

resource vwanHubVPNGW 'Microsoft.Network/vpnGateways@2021-02-01' = if (deployVPNGateway) {
  name: 'vwan-hub-${regionNamePrefix}_S2SvpnGW'
  location: region
  tags: defaultTags
  properties: {
    bgpSettings: {
      asn: 65515
    }
    vpnGatewayScaleUnit: 1
    virtualHub: {
      id: vwanHub.id
    }
  }
}

output outVwanVHubId string = vwanHub.id
