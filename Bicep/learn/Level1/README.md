# Azure-Policy-As-Code/Bicep/Learn/Level1

* Uses built-in policies
* Uses an initiative and assignment
* 1x main.bicep
* This will do a manual CLI deployment

[YouTube Video Timestamp 16m 10s](https://www.youtube.com/watch?v=qpnMJXw6pIg&t=16m10s)

## Minimum Prerequisities

* [azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.20.0
* bicep cli version 0.3.255 (589f0375df)
* [bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) 0.3.1 vscode extension

## Parameters

**Defaults**
```bicep
param policySource string = 'globalbao/azure-policy-as-code'
// Custom refers to Type and Category type in Azure portal
param policyCategory string = 'Custom'
param assignmentEnforcementMode string = 'Default'
param listOfAllowedLocations array = [
  'westeurope'
  //'eastus'
  //'eastus2'
  //'westus'
  //'westus2'
]
param listOfAllowedSKUs array = [
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
  'Standard_D2s_v3'
  'Standard_D4s_v3'
]
```

## Deployment Steps

```s
# optional step to view the JSON/ARM template. Good for trouble shooting
az bicep build -f ./main.bicep

# required steps (in production ue a service principle)
az login
# sub reference to subscription. Can also be management group ... westeurope refers to region 
# Manage Azure Resource Manager template deployment at subscription scope.
az account set --subscription 'subscriptionid'
az deployment sub create -f ./main.bicep -l westeurope
# Delete a deployment
az deployment sub list
az deployment sub delete --name nameofdeployment
# optional step to trigger a subscription-level policy compliance scan 
az policy state trigger-scan --no-wait
```

### Azure Resource Manager (ARM) Template References

* [policy definitions](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policydefinitions?tabs=json)
* [policyset definitions (initiatives)](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policysetdefinitions?tabs=json)
* [policy assignments](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policyassignments?tabs=json)