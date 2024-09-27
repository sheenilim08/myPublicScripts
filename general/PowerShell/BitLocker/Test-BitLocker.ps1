try {
  function main {
    param(
      $organisation,
      [switch]$unlock,
      $kbLink
    )
  
    $encryptedVolumes = [Array]@(Get-BitLockerVolume)
  
    $messageLog = ""
    $errorOccured = $false
    foreach ($volume in $encryptedVolumes) {
      if ($volume.LockStatus -eq "Locked") {
        $currentDate = Get-Date
        $timeStamp = "$($currentDate.ToLongDateString()) $($currentDate.ToLongTimeString()):"
        $messageLog += "<br><br>$($timeStamp) Server $($volume.ComputerName) volume $($volume.MountPoint) is Encrypted and Locked.`n"
  
        if ($unlock) {
          try {
            Unlock-BitLocker -MountPoint $volume.MountPoint
            $messageLog += "$($timeStamp) Server $($volume.ComputerName) volume $($volume.MountPoint) is now unlocked. No further action is required. `n"
          } catch {
            $errorOccured = $true
            $messageLog += "<br><br>$($timeStamp) [Error] Unable to unlock the volume $($volume.MountPoint) on Server $($volume.ComputerName). <br><br>Please check the server itself, reference $($kbLink)`n`n"
          }
        }
      }
    }
  
    if ($errorOccured) {
      Write-Output $messageLog
      Write-Output "<br><br>See Documentation: $($kbLink)"
      exit 1;
    }
  
    Write-Output $messageLog
    Write-Output "The script has completed successfully."
  }
  
  $ErrorActionPreference = 'Continue'
  main -organisation $env:organization -unlock -kbLink $env:kblink
} catch {
  Write-Error $_
  Write-Host "An Error occured while running this script (Test-BitLocker)"
  exit 2
}