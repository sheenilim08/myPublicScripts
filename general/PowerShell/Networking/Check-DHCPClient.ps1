function getAllIPAddOnDhcp() {
  $interfaces = @(Get-NetIPConfiguration -Detailed | Where-Object { $_.NetIPv4Interface.DHCP -eq "Enabled" -and $_.NetAdapter.Status -eq "Up"})
  
  $returnValue = @()
  for ($i=0; $i -lt $interfaces.length; $i++) {
    if (!$interfaces[$i].IPv4Address.IPAddress.StartsWith("169.254.")) {
      $returnValue = $interfaces[$i]
    } else {
      Write-Host "Skipping $($interfaces[$i].InterfaceAlias). Address is APIPA $($interfaces[$i].IPv4Address.IPAddress)"
    }
  }
  
  return $returnValue
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
        $ipDhcpAddresses | Format-Table InterfaceDescription, IPv4Address, InterfaceAlias
        
        Write-Host "Please see documentation. https://modo-networks-llc.itglue.com/1749534/docs/18864948"
        exit 1
    }    
}

main