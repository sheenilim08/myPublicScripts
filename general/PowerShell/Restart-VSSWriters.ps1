# NOTE: Most of the services mentioned here are documented on https://support.storagecraft.com/s/article/Troubleshooting-VSS?language=en_US
# Populate $service_names are you see fit

$service_names = @("vss", "bits", "certsvc", "dfsr", "dhcpserver", "ntfrs", "srmsvc", "apphostsvc", "iisadmin", 
  "MSExchangeRepl", "MSExchangeIS", "MSMQ", "WSearch", "NTDS", "OSearch", "SPSearch", "SQLWriter", "TermServLicensing", 
  "WINS", "Winmgmt", "WIDWriter")

$restartedService = @()
$skippedServices = @()

function Add-SuccessfulServiceRestart($service, $msg = "Service is restarted.") {
  $reason = New-Object -TypeName PSObject
  $reason | Add-Member -MemberType NoteProperty -Name "ServiceName" -Value $thisService.Name
  $reason | Add-Member -MemberType NoteProperty -Name "Reason" -Value $msg
  $restartedService += $reason
}

function Add-FailedServiceRestart($service, $msg = "Service is Disabled.") {
  $reason = New-Object -TypeName PSObject
  $reason | Add-Member -MemberType NoteProperty -Name "ServiceName" -Value $thisService.Name
  $reason | Add-Member -MemberType NoteProperty -Name "Reason" -Value $msg
  $skippedServices += $reason
}

function main() {
  Write-Output "Restarting VSS writers - will restart dependency if there are any.";

  for ($j = 0; $j -lt $service_names.count; $j++) {
    $referenceService = $service_names[$j].tolower()

    $thisService = Get-Service -Name $referenceService -ErrorAction SilentlyContinue
    
    if ($null -ne $thisService) {
      if ($thisService.StartType -eq "Disabled") {
        Write-Output "Service $($thisService.Name) is configured to be disabled. Skipping."

        Add-FailedServiceRestart -service $thisService
        
      } else {
        try {
          Write-Output "Restarting Serivce '$($thisService.Name) - $($thisService.DisplayName)'"
          Restart-Service -Name $thisService.Name -Force

          Add-SuccessfulServiceRestart -service $thisService

        } catch {
          Add-FailedServiceRestart -service $thisService -msg "Service failed to restart"

        }
      }
    } else {
      Write-Output "The service '$($referenceService)' does not exist on this computer."

      $reason = New-Object -TypeName PSObject
      $reason | Add-Member -MemberType NoteProperty -Name "ServiceName" -Value $referenceService
      $reason | Add-Member -MemberType NoteProperty -Name "Reason" -Value "Service does not exist"
      $skippedServices += $reason
    }
  }

  Write-Output ""
  Write-Output "=== Restarted Services ==="
  $restartedService | FT ServiceName, Reason -AutoSize

  Write-Output ""
  Write-Output "=== Skipped Services ==="
  $skippedServices | FT ServiceName, Reason -AutoSize
}

main