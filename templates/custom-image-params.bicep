param location string = resourceGroup().location
param imageTemplateName string = 'myAIBTemplate'
param userAssignedIdentityId string
param scriptUri string
param param1 string
param param2 string

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-07-01' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    source: {
      type: 'PlatformImage'
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
    customize: [
      {
        type: 'PowerShell'
        name: 'RunSetupScript'
        scriptUri: scriptUri
        inline: [
          '-Param1', param1
          '-Param2', param2
        ]
      }
    ]
    distribute: [
      {
        type: 'ManagedImage'
        imageId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/images/myCustomImage'
        location: location
        runOutputName: 'myRunOutput'
      }
    ]
    buildTimeoutInMinutes: 60
  }
}
