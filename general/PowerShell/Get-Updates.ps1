param ($KBNumber)

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
