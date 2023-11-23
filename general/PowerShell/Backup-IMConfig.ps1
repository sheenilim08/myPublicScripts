Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function main() {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  $currentDate = Get-Date
  $timestamp = "$($currentDate.Month)-$($currentDate.Day)-$($currentDate.Year)_$($currentDate.Hour)-$($currentDate.Minute)"

  if ( -not (Test-Path -Path $env:userprofile\IMBackupConfig-Tool )) {
    mkdir $env:userprofile\IMBackupConfig-Tool 
  }

  if ( Test-Path -Path C:\temp ) {
    Write-Output "C:\temp exist renaming it to C:\temp-old-$($timestamp)"
    Move-Item -Path "C:\temp" `
      -Destination "C:\temp-old-$($timestamp)"
  }

  cd $env:userprofile\IMBackupConfig-Tool

  Invoke-WebRequest "https://raw.githubusercontent.com/sheenilim08/myPublicScripts/master/general/PowerShell/common/IMBackup.cmd" -OutFile IMBackup-Tool.cmd

  # Unzip -zipfile $env:userprofile\IMBackupConfig-Tool.zip -outpath $env:userprofile\IMBackupConfig-Tool
  
  .\IMBackup-Tool.cmd
  
  $filename = "ImageManager_Config_backup-$($timestamp).zip"

  Write-Output "Moving exported file to $($env:userprofile)\$($filename)"
  Move-Item  `
    -Path "C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager_Config_backup.zip" `
    -Destination "$($env:userprofile)\$($filename)"

  dir "$($env:userprofile)\$($filename)"

  if ((dir "$($env:userprofile)\$($filename)").Length -lt 1024) {
    Write-Output "The output zip file is less than 1KB, it might be corrupted, please check the contents before doing any doing Image Manager related task."
  }
}

main