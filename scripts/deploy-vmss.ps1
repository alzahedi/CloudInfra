param (
    [string]$resourceGroupName = "alzahedi-bicep-test",
    [string]$bicepFile = "custom-image-params.bicep",
    [string]$userAssignedIdentityName = "arcee-1es",
    [string]$param1 = "Hello",
    [string]$param2 = "World"
)


$currentScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$parentPath = Split-Path -Parent $currentScriptPath
$bicepFilePath = Join-Path $parentPath "templates\$bicepFile"
$scriptPath = Join-Path $parentPath "scripts\download-and-run.ps1"

$userAssignedIdentityId = "/subscriptions/a5082b19-8a6e-4bc5-8fdd-8ef39dfebc39/resourceGroups/arcee-e2e-1es/providers/Microsoft.ManagedIdentity/userAssignedIdentities/arcee-1es"

# Run the deployment
az deployment group create `
    --resource-group $resourceGroupName `
    --template-file $bicepFilePath `
    --parameters userAssignedIdentityId=$userAssignedIdentityId `
                 scriptPath=$scriptPath `
                 param1=$param1 `
                 param2=$param2
