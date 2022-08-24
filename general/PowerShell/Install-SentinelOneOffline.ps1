# Author: Sheen Ismhael Lim
# Usage: the msi installer must be accessible by the script. It can be a local path or a UNC path.
# Example: ./Install-SentinelOneOffline.ps1 -siteToken "YOUR_SITE_TOKEN" -msiInstaller "\\File1.domain.local\Shares\SentinelInstaller.msi" -sha1Value "Expected SHA1 Hash value" -forceReboot $false
# -siteToken and -sha1Value values must be retrieved from the Sentinel Portal
# -siteToken can be a group token in the Sentinel Portal

param(
    [Parameter(HelpMessage="The SITE Token on which the agent will belong to.")]
    $siteToken, 

    [Parameter(HelpMessage="The path of the MSI installer.")]
    $msiInstaller, 

    [Parameter(HelpMessage="The expected SHA1 hash value of the installer.")]
    $sha1Value,

    [Parameter(HelpMessage="Force a reboot after install. False by default.")]
    $forceReboot = $false
)

function main() {
    if (-Not $(Test-Path -Path $msiInstaller)) {
        Write-Output "The installer path is not found or unaccessable."
    }

    $installerSHA1 = $(Get-FileHash -Path $msiInstaller -Algorithm "SHA1").HASH.ToLower()

    if ($installerSHA1 -eq $sha1Value) {
        if ($forceReboot) {
            $msiInstaller SITE_TOKEN=$($siteToken) /QUITE
        } else {
            $msiInstaller SITE_TOKEN=$($siteToken) /QUITE /NORESTART
        }
    }
    #C:\Users\S1\Desktop\Sentinel\SentinelInstaller.msi SITE_TOKEN=<site_Token or group_Token> /QUIET /NORESTART

}

main