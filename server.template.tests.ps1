#requires -Module Az.Accounts,Az.Resources

#region Authenticate to Azure
$azureAdAppId = '21f9ea0e-b668-4cc2-93e0-6f6fd338d57f'
$subscriptionId = '1427e7fb-a488-4ec5-be44-30ac10ca2e95'
$tenantId = '11376bd0-c80f-4e99-b86f-05d17b73518d'
$spPrinPw = $(ServerAutomationDemo-AppPw)

$password = ConvertTo-SecureString $spPrinPw -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($azureAdAppId, $password)

$connectAzParams = @{
    ServicePrincipal = $true
    SubscriptionId   = $subscriptionId
    Tenant           = $tenantId
    Credential       = $credential
}
Connect-AzAccount @connectAzParams
#endregion

$templatePath = Join-Path -Path $(Agent.BuildDirectory) -ChildPath 'server.json'
$resourceGroupName = 'ServerProvisionTesting'

describe 'Template validation' {
    it 'template passes validation check' {
        $parameters = @{
            TemplateFile      = $templatePath
            ResourceGroupName = $resourceGroupName
            adminUsername     = 'adam'
            adminPassword     = (ConvertTo-SecureString -String 'testing' -AsPlainText -Force)
            vmName            = 'TESTING'
        }
        Test-AzResourceGroupDeployment @parameters | should -Benullorempty
    }
}