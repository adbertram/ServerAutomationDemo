[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName
)

#requires -Module Az.Accounts,Az.Resources

describe 'Template validation' {
    it 'template passes validation check' {
        $parameters = @{
            TemplateFile      = 'server.json'
            ResourceGroupName = $ResourceGroupName
            adminUsername     = 'adam'
            adminPassword     = (ConvertTo-SecureString -String 'testing' -AsPlainText -Force)
            vmName            = 'TESTING'
        }
        (Test-AzResourceGroupDeployment @parameters).Details | should -Benullorempty
    }
}