[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Hostname
)

describe 'Network Connnectivity' {
    it 'the VM has RDP/3389 open' {
        Test-Connection -TCPPort 3389 -TargetName $Hostname -Quiet | should -Be $true
    }
}