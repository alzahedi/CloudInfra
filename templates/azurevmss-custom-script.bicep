param location string = 'eastus2'
param vmssName string = 'myVMSS'
param adminUsername string = 'azureuser'

@secure()
param adminPassword string
param vmSize string = 'Standard_D4s_v3'
param instanceCount int = 1
param imageReference object = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}

param scriptUri string = 'https://raw.githubusercontent.com/alzahedi/Pytest-timeout-poc/refs/heads/main/scripts/simulator.ps1'
param scriptCommandToExecute string = 'powershell -ExecutionPolicy Unrestricted -File simulator.ps1'

// Virtual Network
resource vmssName_vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${vmssName}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Network Security Group
resource vmssName_nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${vmssName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowAzureLoadBalancer'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'AllowRDP'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Associate NSG with subnet
resource vmssName_vnet_default 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vmssName_vnet
  name: 'default'
  properties: {
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: vmssName_nsg.id
    }
  }
}

// Virtual Machine Scale Set
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2021-07-01' = {
  name: vmssName
  location: location
  properties: {
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        imageReference: imageReference
        osDisk: {
          createOption: 'FromImage'
          managedDisk: {
            storageAccountType: 'Standard_LRS'
          }
        }
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        adminPassword: adminPassword
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-config'
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: vmssName_vnet_default.id
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
              networkSecurityGroup: {
                id: vmssName_nsg.id
              }
            }
          }
        ]
      }
      extensionProfile: {
        extensions: [
          {
            name: 'customScriptExtension'
            properties: {
              publisher: 'Microsoft.Compute'
              type: 'CustomScriptExtension'
              typeHandlerVersion: '1.10'
              autoUpgradeMinorVersion: true
              settings: {
                fileUris: [scriptUri]
                commandToExecute: scriptCommandToExecute
              }
            }
          }
        ]
      }
    }
  }
  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: instanceCount
  }
}
