Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function main() {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  if ( -not (Test-Path -Path $env:userprofile\IMBackupConfig-Tool )) {
    mkdir $env:userprofile\IMBackupConfig-Tool 
  }

  cd $env:userprofile\IMBackupConfig-Tool

  Invoke-WebRequest "https://raw.githubusercontent.com/sheenilim08/myPublicScripts/master/general/PowerShell/common/IMBackup.cmd" -OutFile IMBackup-Tool.cmd

  # Unzip -zipfile $env:userprofile\IMBackupConfig-Tool.zip -outpath $env:userprofile\IMBackupConfig-Tool
  
  .\IMBackup-Tool.cmd

  $currentDate = Get-Date

  Write-Output "Moving exported file to $($env:userprofile)"
  Move-Item  `
    -Path "C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager_Config_backup.zip" `
    -Destination "$($env:userprofile)\ImageManager_Config_backup-$($currentDate.Month)-$($currentDate.Day)-$($currentDate.Year)_$($currentDate.Hour)-$($currentDate.Minute).zip"
}

main