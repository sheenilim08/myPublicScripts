Write-Host "Setting msedge process to CPU 1"
Get-Process msedge | ForEach-Object { $_.ProcessorAffinity = 1 }
Get-Process OfficeClickToRun | ForEach-Object { $_.ProcessorAffinity = 1 }
Get-Process OneDrive | ForEach-Object { $_.ProcessorAffinity = 1 }
Get-Process ONENOTEM| ForEach-Object { $_.ProcessorAffinity = 1 }
Get-Process olk | ForEach-Object { $_.ProcessorAffinity = 1 } # Outlook New

Write-Host "Setting teams process to CPU 2"
Get-Process teams | ForEach-Object { $_.ProcessorAffinity = 2 }

Write-Host "Setting msedgewebview2 process to CPU 2"
Get-Process msedgewebview2 | ForEach-Object { $_.ProcessorAffinity = 2 }

Write-Host "Setting ConnectWise process to CPU 3"
Get-Process ConnectWiseManage | ForEach-Object { $_.ProcessorAffinity = 4 }
Get-Process ConnectWise | ForEach-Object { $_.ProcessorAffinity = 12 }

Write-Host "Setting SCreenConnect process to CPU 3"
Get-Process ScreenConnect.WindowsClient | ForEach-Object { $_.ProcessorAffinity = 8 }