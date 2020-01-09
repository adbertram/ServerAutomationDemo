[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ArmDeploymentJsonOutput
)

## Parse the ARM output
$ArmDeploymentOutput = $ArmDeploymentJsonOutput | convertfrom-json

## Run the tests
describe 'Network Connnectivity' {
    it 'the VM has RDP/3389 open' {
        Test-Connection -TCPPort 3389 -TargetName $ArmDeploymentOutput.hostname.value -Quiet | should -Be $true
    }
}