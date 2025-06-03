param (
    [string]$blobStorageUrl,
    [string]$param1 = "Hello",
    [string]$param2 = "World"
)

$scriptPath = "C:\Scripts"
New-Item -ItemType Directory -Path $scriptPath -Force | Out-Null

# Get managed identity token for Azure Storage
$resource = "https://storage.azure.com/"
$token = (Invoke-RestMethod -Method Get -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$resource" -Headers @{Metadata="true"}).access_token

# Headers for accessing private blob storage using MSI
$headers = @{
    Authorization = "Bearer $token"
    "x-ms-version" = "2019-02-02"
}

# Download and extract the zip file
$zipFilePath = "$scriptPath\scripts.zip"
$extractPath = "$scriptPath\extracted"
Invoke-WebRequest -Uri $blobStorageUrl -Headers $headers -OutFile $zipFilePath
Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force

# Find the main setup script (assumes it's named setup.ps1)
$setupScript = Join-Path $extractPath "setup.ps1"

# Run the script with parameters
if (Test-Path $setupScript) {
    Write-Host "Running setup script with param1=$param1 and param2=$param2"
    & powershell.exe -ExecutionPolicy Bypass -File $setupScript -param1 $param1 -param2 $param2
} else {
    Write-Error "setup.ps1 not found in extracted archive."
}
