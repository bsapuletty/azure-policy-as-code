// Built-in policy
targetScope = 'subscription' 
//param defaultSubscriptionID  string = 'fbe99a9d-d594-494c-a853-366209b734ba'
// module deployed at subscription level but in a different subscription
//module exampleModule 'main.bicep' = {
//  name: 'deployToDifferentSub'
//  scope: subscription(defaultSubscriptionID)
//}

// PARAMETERS
// Deze parameters zijn voor het description veld in Policy Initiative in Azure Portal
param policySource string = 'globalbao/azure-policy-as-code'
param policyCategory string = 'Custom'
// Enforcement = default: during resource creation
// Enforcement = DoNotEnforce: The policy effect isn't enforced during resource creation or update
// Enforcement =  deployIfNotExists: Remediation tasks can be started for deployIfNotExists policies
// The optional overrides property allows you to change the effect of a policy definition without modifying the underlying policy definition or using a parameterized effect in the policy definition.
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

// VARIABLES
var initiative1Name = 'Initiative1'
var assignment1Name = 'Initiative1'

// OUTPUTS. No definitions because this is a built-in policy
output initiative1ID string = initiative1.id
output assignment1ID string = assignment1.id

// RESOURCES initiative is same as policyset. Afer @ is the API version
// define te Initiative
resource initiative1 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: initiative1Name
  properties: {
    // Custom refers to Type and Category type in Azure portal
    policyType: 'Custom'
    displayName: initiative1Name
    description: '${initiative1Name} via ${policySource}'
    metadata: {
      category: policyCategory
      // source: repo name (is only a marker/comment)
      source: policySource
      version: '0.1.0'
    }
    parameters: {
      listOfAllowedLocations: {
        type: 'Array'
        metadata: ({
          description: 'The List of Allowed Locations for Resource Groups and Resources.'
          strongtype: 'location'
          displayName: 'Allowed Locations'
        })
      }
      listOfAllowedSKUs: {
        type: 'Array'
        metadata: any({
          description: 'The List of Allowed SKUs for Virtual Machines.'
          strongtype: 'vmSKUs'
          displayName: 'Allowed Virtual Machine Size SKUs'
        })
      }
    }
    // Define the policies
    policyDefinitions: [
      {
        //Allowed locations for resource groups. the definition e765b5de-1225-4ba3-bd56-1ac6695af988 relates to "Allowed Locations" for a built-in ID
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        //Allowed locations
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'listOfAllowedLocations\')]'
          }
        }
      }
      {
        //Allowed virtual machine size SKUs
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
        parameters: {
          listOfAllowedSKUs: {
            value: '[parameters(\'listOfAllowedSKUs\')]'
          }
        }
      }
      {
        //Audit virtual machines without disaster recovery configured
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56'
        parameters: {}
      }
    ]
  }
}
//Assign the policy
resource assignment1 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: assignment1Name
    properties: {
    displayName: assignment1Name
    description: '${assignment1Name} via ${policySource}'
    enforcementMode: assignmentEnforcementMode
       metadata: {
      source: policySource
      version: '0.1.0'
    }
    policyDefinitionId: initiative1.id // Reference a policy specified in the same Bicep file
    parameters: {
      listOfAllowedLocations: {
        value: listOfAllowedLocations
      }
      listOfAllowedSKUs: {
        value: listOfAllowedSKUs
      }
    }
  }
}
