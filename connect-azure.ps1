[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ServicePrincipalPassword,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TenantId
)

Install-Module -Name Az.Accounts, Az.Resources -Force -SkipPublisherCheck

$password = ConvertTo-SecureString $ServicePrincipalPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($ApplicationId, $password)

$connectAzParams = @{
    ServicePrincipal = $true
    SubscriptionId   = $SubscriptionId
    Tenant           = $TenantId
    Credential       = $credential
}
Connect-AzAccount @connectAzParams