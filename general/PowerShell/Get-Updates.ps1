param ($KBNumber)

$PSVersion = host
if ($PSVersion.version > 4) {
  Install-Module PSWindowsUpdate -AllowClobber

  $Update = Get-WUList -KBArticleID $KBNumber
  If ($Update) {
      Write-Output "Update found: $($Update.Title)"
      $DownloadedUpdate = $Update | Get-WUDownload
      #$DownloadedUpdate | Install-WUUpdate -AcceptAll -AutoReboot
      $DownloadedUpdate
  } Else {
      Write-Output "No update found with KB number: $KBNumber"
  }
} else {
  $Criteria = "IsInstalled=0 and Type='Software' and IsHidden=0"
  $Searcher = New-Object -ComObject Microsoft.Update.Searcher
  $SearchResult = $Searcher.Search($Criteria).Updates

  $Update = $SearchResult | Where-Object {$_.KBArticleIDs -contains $KBNumber}

  If ($Update) {
      Write-Output "Update found: $($Update.Title)"
      $Session = New-Object -ComObject Microsoft.Update.Session
      $Downloader = $Session.CreateUpdateDownloader()
      $Downloader.Updates = $Update
      $Downloader.Download()
      $Installer = New-Object -ComObject Microsoft.Update.Installer
      $Installer.Updates = $Update
      $Installer.Install()

      If ($Result.RebootRequired) {
        Write-Output "Reboot required to complete the installation of the update."
      }
  } Else {
      Write-Output "No update found with KB number: $KBNumber"
  }

}