function Import-MicrosoftGraphModule {
  param(
    [switch]
    $Force,

    [switch]
    $RequireModule
  )

  $mgModule = Get-InstalledModule -Name Microsoft.Graph -ErrorAction SilentlyContinue
  try {
    if ($null -eq $mgModule) {
      Write-Output "Installing Microsoft.Graph Module."
      if ($Force) {
        Install-Module -Name Microsoft.Graph -Force
      } else {
        Install-Module -Name Microsoft.Graph
      }
    }
  } catch {
    if ($RequireModule) {
      Write-Output "Required Module Microsoft.Graph is not installed. Exiting Script."
      return 1;
    }
  }
}

function Import-ExchangeOnlineModule {
  param(
    [switch]
    $Force,

    [switch]
    $RequireModule
  )
  $exoModule = Get-InstalledModule -Name ExchangeOnlineManagement -ErrorAction SilentlyContinue
  try {
    if ($null -eq $exoModule) {
      Write-Output "Installing ExchangeOnlineManagement Module."
      if ($RequireModule) {
        Install-Module -Name ExchangeOnlineManagement -Force
      } else {
        Install-Module -Name ExchangeOnlineManagement
      }
    }
  } catch {
    if ($RequireModule) {
      Write-Output "Required Module ExichangeOnlineManagement is not installed. Exiting Script."
      return 1;
    }
  }
}