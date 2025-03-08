<!-- TOC depthfrom:2 -->
- [Overview](#overview)
- [Run deployment](#run-deployment)
- [Get output](#get-output)

## overview
This repository contains bicep templates for deploying a azure vm scale set.

The template [azurevmss-custom-script.bicep](./templates/azurevmss-custom-script.bicep) deploys an azure vmss
and runs a custom [script](https://raw.githubusercontent.com/alzahedi/Pytest-timeout-poc/refs/heads/main/scripts/simulator.ps1) downloaded from github. We can then fetch output of the script using `az vmss` commands

## Run deployment

- Git clone the repo
- Do an az login in a powershell terminal
- Navigate to `./templates` directory
- Run `az deployment group create --resource-group <your-resource-group-name> --template-file azurevmss-custom-script.bicep`

## Get Output

In order to get the output of the script run the below command

```powershell
az vmss run-command invoke `
  --resource-group <your resource group name> `
  --name <your vmss name> `
  --instance-id <your vmss instance id> `
  --command-id RunPowerShellScript `
  --scripts "Get-Content C:\Scripts\script_output.log"