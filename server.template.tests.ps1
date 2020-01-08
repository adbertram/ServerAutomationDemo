#requires -Module Az.Accounts,Az.Resources

$templatePath = Join-Path -Path "$(System.DefaultWorkingDirectory)" -ChildPath 'server.json'
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