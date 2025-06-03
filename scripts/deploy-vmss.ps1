param (
    [string]$resourceGroupName = "alzahedi-bicep-test",
    [string]$storageAccountName = "vmssstoragepoc ",
    [string]$containerName = "vmss",
    [string]$blobName = "setup.ps1",
    [string]$bicepFile = "custom-image-params.bicep",
    [string]$userAssignedIdentityName = "arcee-1es",
    [string]$param1 = "Hello",
    [string]$param2 = "World"
)

# Set the expiry for the SAS token
$expiry = (Get-Date).ToUniversalTime().AddDays(1).ToString("yyyy-MM-ddTHH:mmZ")

# Get the storage account key
$accountKey = (az storage account keys list `
    --resource-group $resourceGroupName `
    --account-name $storageAccountName `
    --query '[0].value' -o tsv)

# Generate the SAS token
$sasToken = az storage blob generate-sas `
    --account-name $storageAccountName `
    --container-name $containerName `
    --name $blobName `
    --permissions r `
    --expiry $expiry `
    --account-key $accountKey `
    -o tsv

# Build full script URI
$scriptUri = "https://$storageAccountName.blob.core.windows.net/$containerName/$blobName?$sasToken"

$currentScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$parentPath = Split-Path -Parent $currentScriptPath
$bicepFilePath = Join-Path $parentPath "templates\$bicepFile"

# Build user-assigned identity resource ID
$subscriptionId = (az account show --query id -o tsv)
$userAssignedIdentityId = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$userAssignedIdentityName"

# Run the deployment
az deployment group create `
    --resource-group $resourceGroupName `
    --template-file $bicepFilePath `
    --parameters userAssignedIdentityId=$userAssignedIdentityId `
                 scriptUri=$scriptUri `
                 param1=$param1 `
                 param2=$param2
