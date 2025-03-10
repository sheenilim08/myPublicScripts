function getAllIPAddOnDhcp() {
    return Get-NetIPConfiguration -Detailed | Where-Object { $_.NetIPv4Interface.DHCP -eq "Enabled" -and $_.NetAdapter.Status -eq "Up"}
}
function main() {
    try {
        $ipDhcpAddresses = @(getAllIPAddOnDhcp)
    } catch {
        Write-Host "The script failed while trying to run 'Get-NetIPConfiguration' to get the Interface IP addresses on the endpoint."
        exit 2
    }

    if ($ipDhcpAddresses.Length -gt 0) {
        Write-Host "The following IP Addresses are set by DHCP."
        $ipDhcpAddresses | Format-Table InterfaceDescription, IPv4Address, NetIPv4Interface.DHCP
        exit 1
    }    
}

main