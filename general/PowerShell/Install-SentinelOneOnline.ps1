param(
    [Parameter(HelpMessage="The SITE Token on which the agent will belong to.")]
    $siteToken, 

    [Parameter(HelpMessage="The expected SHA1 hash value of the installer.")]
    $sha1Value,

    [Parameter(HelpMessage="Force a reboot after install. False by default.")]
    $forceReboot = $false

    [Parameter(HelpMessage="Installer URI")]
    $installerURI = $false
)

function main() {
    #C:\Users\S1\Desktop\Sentinel\SentinelInstaller.msi SITE_TOKEN=<site_Token or group_Token> /QUIET /NORESTART
}

main