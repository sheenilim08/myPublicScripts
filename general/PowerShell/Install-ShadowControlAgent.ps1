function main {
  param(
    [Parameter(HelpMessage="The host where the shadowcontrol will report to.")]
    $shadowControlApplianceHost, 

    [Parameter(HelpMessage="The admin username that will be used to login to the host.")]
    $username, 

    [Parameter(HelpMessage="The Organization that the agent will belong to.")]
    $password, 

    [Parameter(HelpMessage="The Organization that the agent will belong to.")]
    $orgName,
    
    [Parameter(HelpMessage="The Organization that the agent will belong to.")]
    $siteName, 

    [Parameter(HelpMessage="The type of endpoint to be added. Values can be 'Desktop' 'Server' 'Laptop', 'Virtual'")]
    $type="server", 

    [Parameter(HelpMessage="The url where to download the Shadow Control Agent.")]
    $url
  )

  Write-Output "Downloading from '$($url)'"
  Invoke-WebRequest $url -OutFile ShadowControl_Installer.msi

  Write-Output "Installing the ShadowControl Agent"
  Start-Process -FilePath "c:\windows\system32\msiexec.exe" -Verb RunAs -ArgumentList "/i .\ShadowControl_Installer.msi /qn /norestart"

  Write-Output "Subscribing to $($shadowControlApplianceHost)."
  Set-Location "C:\Program Files (x86)\StorageCraft\CMD"
  try {
    .\stccmd.exe subscribe -o "$($orgName):$($siteName)" -U $($username) -P $($password) -m $($type) "$($shadowControlApplianceHost)";
    Write-Output "ShadowControl has been installed and subscribed to $($shadowControlApplianceHost)."
  } catch {
    Write-Output "An issue occured while subscribing to $($shadowControlApplianceHost)."
  }
}

main -shadowControlApplianceHost "myhost" -username "username" -password "password" -orgName "orgName" -siteName "siteName" -type "server" -url "url"