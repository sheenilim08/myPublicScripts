$shadowControlApplianceHost = $env:shadowcontrolappliancehost_param
$siteToken = $env:sitetoken_param
$orgName = $env:orgname_param
$siteName = $env:sitename_param
$type= $env:type_param
$url=$env:url_param

function main {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  Write-Output "Downloading from '$($url)'"
  Invoke-WebRequest $url -OutFile ShadowControl_Installer.msi
  Unblock-File ShadowControl_Installer.msi

  Write-Output "Installing the ShadowControl Agent"
  Start-Process msiexec.exe  -Argumentlist "/i ShadowControl_Installer.msi /qn /norestart /lev ShadowControlInstall.log" -wait

  Write-Output "Subscribing to $($shadowControlApplianceHost)."
  Set-Location "C:\Program Files (x86)\StorageCraft\CMD"
  try {
    $orgAndSite = "";
    
    if ($($siteName) -eq '') {
      $orgAndSite = "$($orgName):"
    } else {
      $orgAndSite = "$($orgName):$($siteName)"
    }
    .\stccmd.exe subscribe -o "$($orgAndSite)" -T $siteToken -m $type "$($shadowControlApplianceHost)";
    Write-Output "ShadowControl has been installed and subscribed to $($shadowControlApplianceHost)."
  } catch {
    Write-Output "An issue occured while subscribing to $($shadowControlApplianceHost)."
  }
}

main
