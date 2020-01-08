[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ServicePrincipalPassword
)

Install-Module -Name Az.Accounts, Az.Resources -Force -SkipPublisherCheck

$azureAdAppId = '21f9ea0e-b668-4cc2-93e0-6f6fd338d57f'
$subscriptionId = '1427e7fb-a488-4ec5-be44-30ac10ca2e95'
$tenantId = '11376bd0-c80f-4e99-b86f-05d17b73518d'

$password = ConvertTo-SecureString $ServicePrincipalPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($azureAdAppId, $password)

$connectAzParams = @{
    ServicePrincipal = $true
    SubscriptionId   = $subscriptionId
    Tenant           = $tenantId
    Credential       = $credential
}
Connect-AzAccount @connectAzParams