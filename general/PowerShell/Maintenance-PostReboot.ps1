$startRunningServices = [System.Boolean]::Parse($env:startrunningservices)
$filenameSuffix = $env:filenamesuffix


$services_csvFile = ""
$ipconfig_csvFile = ""
$volume_csvFile = ""

function main {
  if ($null -eq $filenameSuffix -or $filenameSuffix -eq "") {
    $services_csvFile = "C:\Windows\System32\pre-reboot-service-status.csv"
    #$ipconfig_csvFile = "C:\Windows\System32\pre-reboot-ipconfig.csv"
    #$volume_csvFile = "C:\Windows\System32\pre-reboot-partitions.csv"
  } else {
    $services_csvFile = "C:\Windows\System32\pre-reboot-service-status_$($filenameSuffix).csv"
    #$ipconfig_csvFile = "C:\Windows\System32\pre-reboot-ipconfig_$($filenameSuffix).csv"
    #$volume_csvFile = "C:\Windows\System32\pre-reboot-partitions_$($filenameSuffix).csv"
  }
  
  if (-Not (Test-Path -LiteralPath $services_csvFile)) {
    Write-Host "Unable to locate the services csv file $($services_csvFile)"
    Write-Host "<br><br>See Documentation: https://modo-networks-llc.itglue.com/1749534/docs/17159216<br>"
    exit 1
  }
  
  #if (-Not (Test-Path -LiteralPath $ipconfig_csvFile)) {
  #  Write-Host "Unable to locate the ipconfig csv file $($ipconfig_csvFile)"
  #  exit 1
  #}
  
  #if (-Not (Test-Path -LiteralPath $volume_csvFile)) {
  #  Write-Host "Unable to locate the volumes csv file $($volume_csvFile)"
  #  exit 1
  #}

  Write-Host "<br>Checking Services."
  Write-Host "<br>Loading CSV File '$($services_csvFile)'<br><br>"
  $csvServiceList = Import-Csv -Path "$($services_csvFile)"

  $serviceFailedOrMissing = @()

  for ($i=0; $i -lt $csvServiceList.Length; $i++) {
    if ($csvServiceList[$i].Name.Contains("CaptureService_") -or # CaptureService_
    $csvServiceList[$i].Name.Contains("CDPUserSvc_") -or # Connected Devices Platform User Service_
    $csvServiceList[$i].Name.Contains("ConsentUxUserSvc_") -or # ConsentUX User Service_
    $csvServiceList[$i].Name.Contains("PimIndexMaintenanceSvc_") -or # Contact Data_
    $csvServiceList[$i].Name.Contains("CredentialEnrollmentManagerUserSvc_") -or # CredentialEnrollmentManagerUserSvc_
    $csvServiceList[$i].Name.Contains("DeviceAssociationBrokerSvc_") -or # DeviceAssociationBroker_
    $csvServiceList[$i].Name.Contains("DevicePickerUserSvc_") -or # DevicePicker_
    $csvServiceList[$i].Name.Contains("UdkUserSvc_") -or # Udk User Service_
    $csvServiceList[$i].Name.Contains("UnistoreSvc_") -or # User Data Storage_
    $csvServiceList[$i].Name.Contains("UserDataSvc_") -or # User Data Access_
    $csvServiceList[$i].Name.Contains("WpnUserService_") -or # Windows Push Notifications User Service_
    $csvServiceList[$i].Name.Contains("DevicesFlowUserSvc_") -or # DevicesFlow_
    $csvServiceList[$i].Name.Contains("PrintWorkflowUserSvc_") -or # PrintWorkflow_
    $csvServiceList[$i].Name.Contains("OneSyncSvc_") -or # Sync Host_
    $csvServiceList[$i].Name.Contains("aella_") -or # Windows Agent Sensor *
    $csvServiceList[$i].Name.Contains("WdiSystemHost") -or # Diagnostic System Host
    $csvServiceList[$i].Name.Contains("WdiServiceHost") -or # Diagnostic Service Host
    $csvServiceList[$i].Name.Contains("smphost") -or # Microsoft Storage Spaces SMP
    $csvServiceList[$i].Name.Contains("AarSvc_") -or # Agent Activation Runtime
    $csvServiceList[$i].Name.Contains("BcastDVRUserService_") -or # GameDVR and Broadcast User Service
    $csvServiceList[$i].Name.Contains("MessagingService_") -or # MessagingService
    $csvServiceList[$i].Name.Contains("BluetoothUserService_") -or # Bluetooth User Support Service
    $csvServiceList[$i].Name.Contains("GoogleUpdaterService") -or # GoogleUpdater Service
    $csvServiceList[$i].Name.Contains("GoogleUpdaterInternalService") -or # GoogleUpdater InternalService
    $csvServiceList[$i].Name.Contains("cbdhsvc_")) { # Clipboard User Service_
      # These services are dynamically created as users connect to a RDS server
      # Skip check
      continue;
    }
    
    $currentServiceOutputDisplayName = "'$($csvServiceList[$i].Name)' - '$($csvServiceList[$i].DisplayName)'"
    $currentService = Get-Service -Name $csvServiceList[$i].Name -ErrorAction SilentlyContinue

    if ($null -eq $currentService) {
      Write-Host "<br>Service $($currentServiceOutputDisplayName) cannot be found, perhaps this service was removed or renamed post reboot.<br>"
      $serviceFailedOrMissing += $csvServiceList[$i]
      continue;
    }

    if ($currentService.Status -eq "Starting") {
      Start-Sleep -Seconds 30
      
      if ($currentService.Status -eq "Starting") {
        Write-Host "`n Service '$($csvServiceList[$i].Name)' - '$($csvServiceList[$i].DisplayName)' is stuck at starting.`n"
        $serviceFailedOrMissing += $csvServiceList[$i]
        continue;
      }
    }

    if (($currentService.Status -eq "Stopped") -and ($csvServiceList[$i].Status -eq "Running")) {
      if ($startRunningServices) {
        Write-Host "`nStarting $($currentServiceOutputDisplayName)`n"
        try {
          Start-Service -Name $currentService.Name -ErrorAction Stop
        } catch {
          $serviceFailedOrMissing += $csvServiceList[$i]
          continue;
        }
        
      } else {
        Write-Host "Would have started $($currentServiceOutputDisplayName)"
      }
    }
  }

  if ($serviceFailedOrMissing.Length -gt 0) {
    Write-Host "<br><br>The following Serivces cannot be started.<br>"
    for ($i=0; $i -lt $serviceFailedOrMissing.Length; $i++) {
        Write-host "$($serviceFailedOrMissing[$i].Name) - $($serviceFailedOrMissing[$i].DisplayName)<br>"
    }
    Write-Host "<br><br>See Documentation: https://modo-networks-llc.itglue.com/1749534/docs/17159216<br>"
    exit 1;
  }
}

try {
  main
} catch {
  Write-Error $_
  exit 2
}