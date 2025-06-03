param location string = resourceGroup().location
param imageTemplateName string = 'myAIBTemplate'
param userAssignedIdentityId string
param scriptPath string
param param1 string
param param2 string

param blobStorageUrl string = 'https://vmssstoragepoc.blob.core.windows.net/vmss/poc-setup.zip'

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
        inline: [
          'powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}" -blobStorageUrl "${blobStorageUrl}" -param1 "${param1}" -param2 "${param2}"'
        ]
        runElevated: true
      }
    ]
    distribute: [
      {
        type: 'ManagedImage'
        location: location
        runOutputName: 'myRunOutput'
        imageId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/images/myCustomImage'
      }
    ]
    buildTimeoutInMinutes: 60
  }
}
