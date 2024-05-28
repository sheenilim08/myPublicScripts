function main() {
  $currentTimeDate = (get-date).ToString('MMM-dd-yyyy_HH-mm-ss')

  $prefferedFileName = "$($env:computername)_$($currentTimeDate)"

  Write-Output "Retreiving Services"
  Get-Service | Select DisplayName, name, StartType, Status | export-csv "pre-reboot-service-status_$($prefferedFileName).csv"

  Write-Output "Retriving ipconfig /all information"
  ipconfig > "pre-reboot-ipconfig_$($prefferedFileName).txt"

  Write-Output "Retreiving Volume Information"
  Get-Volume > "pre-reboot-volume_$($prefferedFileName).txt"

  Write-Output "Restarting Machine"
  Restart-Computer -Force
}

main