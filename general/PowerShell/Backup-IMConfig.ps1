Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function main() {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  Invoke-WebRequest "https://arcserve.file.force.com/sfc/dist/version/download/?oid=00D36000000JVmG&ids=0683600000DCuCHAA1&d=%2Fa%2F36000000DFQK%2F1kv.e1ULZhByGtQEGKLqUUxj6oeC49OvGS1vyUVg3d4&operationContext=DELIVERY&viewId=05HHq00000J7kq4MAB&dpt=" -OutFile "$env:userprofile\IMBackupConfig.zip"

  Unzip -zipfile $env:userprofile\IMBackupConfig.zip -outpath $env:userprofile\IMBackupConfig
  cd $env:userprofile\IMBackupConfig
  
  Get-Content IMBackup.cmd | Select-String -pattern "pause" -notmatch | Out-File IMBackup-nopause.cmd
  .\IMBackup-nopause.cmd

  $currentDate = Get-Date

  Write-Output "Moving exported file to $($env:userprofile)"
  Move-Item  `
    -Path "C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager_Config_backup.zip" `
    -Destination "$($env:userprofile)\ImageManager_Config_backup-$($currentDate.Month)-$($currentDate.Day)-$($currentDate.Year)_$($currentDate.Hour)-$($currentDate.Minute).zip"
}

main