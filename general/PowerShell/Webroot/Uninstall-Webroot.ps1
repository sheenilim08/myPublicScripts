param($rebootAfter)
function main {
    $wrExe = "";
    if ([Environment]::Is64BitProcess -ne [Environment]::Is64BitOperatingSystem) {
        Write-Host "System is 32bit."
        $wrExe = "C:\Program Files\Webroot\WRSA.exe"
        
    } else {
        Write-Host "System is 64bit."
        $wrExe = "C:\Program Files (x86)\Webroot\WRSA.exe"

    }

    Write-Host "Performing Uninstall."
    Start-Process -FilePath $wrExe -ArgumentList "-uninstall" -Wait
    Write-Host "Performing Uninstall - Completed."

    Set-Location -Path $env:ProgramData

    # If Anti-Tampering is enabled, the service cannot be stopped after running the uninstall and will lock this folder which fails the remote-item code.
    if (Test-Path -Path "$($env:ProgramData)\WRData") {
        Write-Host "Removing $($env:ProgramData)\WRData folder."
        Remove-Item -Path "WRData" -Recurse -Force
    }
    
    # If Anti-Tampering is enabled, the service cannot be stopped after running the uninstall and will lock this folder which fails the remote-item code.
    if (Test-Path -Path "$($env:ProgramData)\WRCore") {
        Write-Host "Removing $($env:ProgramData)\WRCore folder."
        Remove-Item -Path "WRCore" -Recurse -Force
    }

    if ([System.Boolean]::Parse($rebootafter)) {
        Write-Host "Rebooting endpoint"
        Restart-Computer -Timeout 0
        
    } else {
      Write-Host "Skipping Reboot. Reboot is required to complete uninstall."
    }
}

main