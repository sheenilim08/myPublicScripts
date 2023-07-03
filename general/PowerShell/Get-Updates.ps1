param ($KBNumber)

$PSVersion = host
if ($PSVersion.version > 4) {
  Install-Module PSWindowsUpdate -AllowClobber -Force

  $Update = Get-WUList -KBArticleID $KBNumber
  if ($Update) {
      Write-Output "Update found: $($Update.Title)"
      $DownloadedUpdate = $Update | Get-WUDownload
      #$DownloadedUpdate | Install-WUUpdate -AcceptAll -AutoReboot
      $DownloadedUpdate
  } else {
      Write-Output "No update found with KB number: $KBNumber"
  }
} else {
  $Criteria = "IsInstalled=0 and Type='Software' and IsHidden=0 and CategoryIDs contains '0FA1201D-4330-4FA8-8AE9-B877473B6441'"
  $Searcher = New-Object -ComObject Microsoft.Update.Searcher
  $SearchResult = $Searcher.Search($Criteria).Updates

  Write-Output "The following updates are available for this computer."
  $SearchResult | FT KBArticleIDs, Title -AutoSize -Wrap

  $Update = $SearchResult | Where-Object {
    $_.Title.ToString().ToLower().contains($KBNumber.ToLower())
  }

  if ($Update) {
      Write-Output "Update found: $($Update.Title)"
      $Session = New-Object -ComObject Microsoft.Update.Session
      $Downloader = $Session.CreateUpdateDownloader()
      $Installer = $Session.CreateUpdateInstaller()

      $DownloadCollection = New-Object -ComObject Microsoft.Update.UpdateColl
      $DownloadCollection.Add($Update)
      $Downloader.Updates = $DownloadCollection

      $InstallCollection = New-Object -ComObject Microsoft.Update.UpdateColl
      $InstallCollection.Add($Update)
      $Installer.Updates = $InstallCollection

      Write-Output "Downloading $($Update.Title)"
      $Downloader.Download()

      Write-Output "Installing $($Update.Title)"
      $installResult = $Installer.Install()

      if ($installResult.ResultCode -eq 2) {
          Write-Output "Reboot required to complete the installation of the update."
      }
  } else {
      Write-Output "No update found with KB number: $KBNumber"
  }

}