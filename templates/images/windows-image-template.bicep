param location string = 'eastus'
param imageTemplateName string = 'myImageTemplate'
param resourceGroupName string = 'alzahedi-bicep-test'
param managedImageName string = 'myManagedWindowsImage'
param subscriptionId string = 'a5082b19-8a6e-4bc5-8fdd-8ef39dfebc39'
param installScriptUrl string = 'https://raw.githubusercontent.com/alzahedi/Pytest-timeout-poc/refs/heads/main/scripts/setup.ps1'
param identityId string = '/subscriptions/a5082b19-8a6e-4bc5-8fdd-8ef39dfebc39/resourceGroups/arcee-e2e-1es/providers/Microsoft.ManagedIdentity/userAssignedIdentities/arcee-1es'


resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2024-02-01' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    vmProfile: {
      vmSize: 'Standard_D2s_v3'
      osDiskSizeGB: 127
    }
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
        name: 'InstallPython'
        inline: [
           'Set-ExecutionPolicy Bypass -Scope Process -Force'
           '[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072'
           'iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))'
           'choco install python310 --yes'
        ]
      }
    ]
    distribute: [
      {
        type: 'ManagedImage'
        imageId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Compute/images/${managedImageName}'
        runOutputName: managedImageName
        location: location
      }
    ]
  }
}
