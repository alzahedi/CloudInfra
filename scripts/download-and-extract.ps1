param (
    [string]$blobStorageUrl
)

$scriptPath = "C:\Scripts"
New-Item -ItemType Directory -Path $scriptPath -Force | Out-Null

$resource = "https://storage.azure.com/"
$token = (Invoke-RestMethod -Method Get -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$resource" -Headers @{Metadata="true"}).access_token

# Set up headers for blob access
$headers = @{
        Authorization = "Bearer $token"
        "x-ms-version" = "2019-02-02"
}

$zipFilePath = "$scriptPath\scripts.zip"
$extractPath = "$scriptPath\extracted"

Invoke-WebRequest -Uri $blobStorageUrl -Headers $headers -OutFile $zipFilePath
Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
Write-Host "Script execution completed. Files extracted to: $extractPath"