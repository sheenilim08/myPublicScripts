$doNotReboot = [System.Boolean]::Parse($env:doNotReboot)
$shutdown = [System.Boolean]::Parse($env:shutdown)

function main() {
  $currentTimeDate = (get-date).ToString('MMM-dd-yyyy_HH-mm-ss')

  $prefferedFileName = "$($env:computername)_$($currentTimeDate)"

  Write-Host "Filename Suffix: '$($prefferedFileName)'"

  Write-Output "Retreiving Services"
  Get-Service | Select-Object DisplayName, Name, StartType, Status | Export-Csv "pre-reboot-service-status_$($prefferedFileName).csv"

  Write-Output "Retriving ipconfig /all information"
#   Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"} | Select-Object InterfaceIndex, InterfaceAlias, IPAddress | Export-Csv "pre-reboot-ipconfig_$($prefferedFileName).csv"
  Get-NetIPConfiguration -Detailed | Select-Object InterfaceIndex, InterfaceAlias, IPv4Address, IPv4DefaultGateway, NetAdapter.LinkLayerAddress, NetIPv4Interface.DHCP | Export-Csv "pre-reboot-ipconfig_$($prefferedFileName).csv"

  Write-Output "Retreiving Volume Information"
  Get-Volume > "pre-reboot-volume_$($prefferedFileName).txt"

  if ($shutdown)   {
    Write-Host "Shutting down Machine."
    Stop-Computer 
  }

  if (!$doNotReboot) {
    Write-Output "Restarting Machine."
    Restart-Computer -Force
  }
}

main