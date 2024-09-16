$startRunningServices = [System.Boolean]::Parse($env:startrunningservices)
$filenameSuffix = $env:filenamesuffix

function Test-Services {
  param($filenameSuffix)

  Write-Host "Checking Services."
  $csvFile = "C:\Windows\System32\pre-reboot-service-status_$($filenameSuffix).csv"
  Write-Host "Loading CSV File '$($csvFile)'"
  $csvServiceList = Import-Csv -Path "$($csvFile)"

  for ($i=0; $i -lt $csvServiceList.Length; $i++) {
    $currentServiceOutputDisplayName = "'$($csvServiceList[$i].Name)' - '$($csvServiceList[$i].DisplayName)'"
    $currentService = Get-Service -Name $csvServiceList[$i].Name -ErrorAction SilentlyContinue

    if ($null -eq $currentService) {
      Write-Host "Service $($currentServiceOutputDisplayName) cannot be found, perhaps this service was removed pre reboot."
      continue;
    }

    if ($currentService.Status -ne $csvServiceList[$i].Status -and $csvServiceList[$i].Status -eq "Running") {
      if ($startRunningServices) {
        Write-Host "Starting $($currentServiceOutputDisplayName)"
        Start-Service -Name $currentService.Name
      } else {
        Write-Host "Would have started $($currentServiceOutputDisplayName)"
      }
    }
  }
  
  Write-Host "Finished Checking Services"
}

function Test-IPInterface {
  param($filenameSuffix)

  Write-Host "Checking IP Interfaces"
  $ipAddresses = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"} | Select-Object InterfaceIndex, InterfaceAlias, IPAddress

  $csvFile = "C:\Windows\System32\pre-reboot-service-status_$($filenameSuffix).csv"
  Write-Host "Loading CSV File '$($csvFile)'"
  $csvFileIPInterfacesPreReboot = Import-Csv -Path "$($csvFile)"

  for ($i=0; $i -lt $csvFileIPInterfacesPreReboot.Length; $i++) {
    $currentIntIndex = Get-NetIPAddress -InterfaceIndex $csvFileIPInterfacesPreReboot[$i].InterfaceIndex -AddressFamily IPv4

    
  }
}

function main {
  Test-Services -filenameSuffix $filenameSuffix
}

main