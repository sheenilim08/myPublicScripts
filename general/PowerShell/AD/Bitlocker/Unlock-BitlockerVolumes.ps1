param(
  $organisation,
  $to,
  $from,
  $smtpServer,
  [switch]$ssl,
  [switch]$unlock,
  $kbLink
)

function Send-EmailNotification {
  param(
    $emailBody
  )

  if ($ssl) { Send-MailMessage -To $to -From $from -Subject "BitLocker Check Notification $($organisation)" -Body $emailBody -UseSsl -SmtpServer $smtpServer }
  else { Send-MailMessage -To $to -From $from -Subject "BitLocker Check Notification $($organisation)" -Body $emailBody -UseSsl -SmtpServer $smtpServer }
}

function main() {
  $encryptedVolumes = [Array]@(Get-BitLockerVolume)

  $messageLog = ""
  foreach ($volume in $encryptedVolumes) {
    if ($volume.LockStatus -eq "Locked") {
      $currentDate = Get-Date
      $timeStamp = "$($currentDate.ToLongDateString()) $($currentDate.ToLongTimeString()):"
      $messageLog += "$($timeStamp) Server $($volume.ComputerName) volume $($volume.MountPoint) is Encrypted and Locked.`n"

      if ($unlock) {
        try {
          Unlock-BitLocker -MountPoint $volume.MountPoint
          $messageLog += "$($timeStamp) Server $($volume.ComputerName) volume $($volume.MountPoint) is now unlocked. No further action is required. `n"
        } catch {
          $messageLog += "$($timeStamp) Unable to unlock the volume $($volume.MountPoint) on Server $($volume.ComputerName). Please check $($kbLink)`n`n"
        }
      }
    }
  }

  Send-EmailNotification -emailBody $messageLog
}

$ErrorActionPreference = 'Continue'
main