# Reference Documentation:
# https://learn.microsoft.com/en-us/microsoftteams/new-teams-bulk-install-client#option-1b-download-and-install-new-teams-using-an-offline-installer
function main {
    param(
        $bootStrapInstaller = "https://statics.teams.cdn.office.net/production-teamsprovision/lkg/teamsbootstrapper.exe", 
        $appxInstaller = "https://statics.teams.cdn.office.net/production-windows-x64/enterprise/webview2/lkg/MSTeams-x64.msix"
    )

    Write-Output "Setting Client Session to TLS1.2"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Write-Output "Downloading BoootStrap Installer from '$($bootStrapInstaller)'"
    Invoke-WebRequest $bootStrapInstaller -OutFile bootStrap_Installer.exe
    Unblock-File bootStrap_Installer.exe

    Write-Output "Downloading MSIX installer from '$($appxInstaller)'"
    Invoke-WebRequest $appxInstaller -OutFile appx_Installer.msix
    Unblock-File appx_Installer.msix

    Write-Output "Installing Teams 2 (New Teams)."
    Start-Process cmd.exe -Argumentlist "bootStrap_Installer.exe -p -o appx_Installer.msix" -wait
}

main