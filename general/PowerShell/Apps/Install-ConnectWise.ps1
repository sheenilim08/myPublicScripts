function main {
    param(
        $cwManageInstaller = "https://university.connectwise.com/install/ConnectWise-Internet-Client-x64.msi"
    )

    $installerFileName = "cw_installer.msi"
    Write-Output "Cleaning up old residue."
    if (Test-Path -Path $installerFileName) {
      Write-Output "Deleting $($installerFileName)"
      Remove-Item -Path $installerFileName -Force
    }
    
    Write-Output "Setting Client Session to TLS1.2"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Write-Output "Downloading BoootStrap Installer from '$($cwManageInstaller)'"
    Invoke-WebRequest $cwManageInstaller -OutFile $installerFileName
    Unblock-File $installerFileName

    Write-Output "Installing ConnectWise Manage."
    Set-Location -Path "C:\Windows\system32\"
    Start-Process msiexec.exe -Argumentlist "/i $($installerFileName) /qn /norestart /lev cw_manageinstaller.log" -wait
}

main