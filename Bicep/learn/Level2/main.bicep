//Custom policy. Bicep code uses paramter file for flexibility
targetScope = 'subscription'
// PARAMETERS
param policySource string = 'globalbao/azure-policy-as-code'
param policyCategory string = 'Custom'
param assignmentIdentityLocation string //level2 difference with level1
param mandatoryTag1Key string = 'BicepTagName' //level2
param mandatoryTag1Value string //level2
param assignmentEnforcementMode string = 'Default'
param listOfAllowedLocations array = [
  'australiaeast'
  'australiasoutheast'
]
param listOfAllowedSKUs array = [
  'Standard_B1ls'
  'Standard_B1ms'
  'Standard_B1s'
  'Standard_B2ms'
  'Standard_B2s'
  'Standard_B4ms'
  'Standard_B4s'
]

// VARIABLES
var initiative1Name = 'Initiative1'
var assignment1Name = 'Initiative1'
var initiative2Name = 'Initiative2' //level2
var assignment2Name = 'Initiative2' //level2

// OUTPUTS for structure. When you have more bicep files, than you use
output initiative1ID string = initiative1.id
output initiative2ID string = initiative2.id //level2
output assignment1ID string = assignment1.id
output assignment2ID string = assignment2.id //level2

// Custom policies with the chosen name 'policy'
resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  //level2
  name: 'addTagToRG'
  properties: {
    displayName: 'Add tag to resource group'
    policyType: 'Custom'
    mode: 'All'
    description: 'Adds the mandatory tag key when any resource group missing this tag is created or updated. Existing resource groups can be remediated by triggering a remediation task. If the tag exists with a different value it will not be changed.'
    metadata: {
      category: policyCategory
      source: policySource
      version: '0.1.0'
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Mandatory Tag ${mandatoryTag1Key}'
          description: 'Name of the tag, such as ${mandatoryTag1Key}'
        }
        defaultValue: 'BicepTagName'
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag Value ${mandatoryTag1Value}'
          description: 'Value of the tag, such as ${mandatoryTag1Value}'
        }
        defaultValue: 'tempvalue'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            // Als tagName 'BicepTagName' niet bestaat, than false en voer effect modify uit
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
            exists: 'false'
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            // because of modify effect we need a managed identity with the contributor role
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c' 
          ]
          operations: [
            {
              operation: 'add'
              field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
              value: '[parameters(\'tagValue\')]'
            }
          ]
        }
      }
    }
  }
}
//for built-in policy
resource initiative1 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: initiative1Name
  properties: {
    policyType: 'Custom'
    displayName: initiative1Name
    description: '${initiative1Name} via ${policySource}'
    metadata: {
      category: policyCategory
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
    policyDefinitions: [
      {
        //Allowed locations for resource groups
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
// for custom policy
resource initiative2 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  //level2
  name: initiative2Name
  properties: {
    policyType: 'Custom'
    displayName: initiative2Name
    description: '${initiative2Name} via ${policySource}'
    metadata: {
      category: policyCategory
      source: policySource
      version: '0.1.0'
    }
    parameters: {
      tagName: {
        type: 'String'
        metadata: ({
          displayName: 'Mandatory Tag ${mandatoryTag1Key}'
          description: 'Name of the tag, such as ${mandatoryTag1Key}'
        })
      }
      tagValue: {
        type: 'String'
        metadata: ({
          displayName: 'Tag Value ${mandatoryTag1Value}'
          description: 'Value of the tag, such as ${mandatoryTag1Value}'
        })
      }
    }
    policyDefinitions: [
      {
        //Add tag to resource group
        //reference to policy (name given to policy resource above)
        policyDefinitionId: policy.id
        parameters: {
          tagName: {
            value: '[parameters(\'tagName\')]'
          }
          tagValue: {
            value: '[parameters(\'tagValue\')]'
          }
        }
      }
    ]
  }
}
//for built-in policy
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
    policyDefinitionId: initiative1.id
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
// for custom policy
resource assignment2 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  //level2
  name: assignment2Name
  location: assignmentIdentityLocation // is passed in from jason file params-devtest.jason
  identity: {
    type: 'SystemAssigned' // a system assigned identity is used in case of a modification
  }
  properties: {
    displayName: assignment2Name
    description: '${assignment2Name} via ${policySource}'
    enforcementMode: assignmentEnforcementMode
    metadata: {
      source: policySource
      version: '0.1.0'
    }
    policyDefinitionId: initiative2.id
    parameters: {
      tagName: {
        value: mandatoryTag1Key
      }
      tagValue: {
        value: mandatoryTag1Value
      }
    }
  }
}
