function Import-PartnerCenterModule {
  param(
    [switch]
    $Force,

    [switch]
    $RequireModule
  )

  $pcModule = Get-InstalledModule -Name PartnerCenter -ErrorAction SilentlyContinue
  try {
    if ($null -eq $pcModule) {
      Write-Output "Installing PartnerCenter Module."
      if ($Force) {
        Install-Module -Name PartnerCenter -Force
      } else {
        Install-Module -Name PartnerCenter
      }
    }
  } catch {
    if ($RequireModule) {
      Write-Output "Required Module PartnerCenter is not installed. Exiting Script."
      return 1;
    }
  }
}

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
        Install-Module -Name ExchangePowerShell -Force
      } else {
        Install-Module -Name ExchangeOnlineManagement
        Install-Module -Name ExchangePowerShell
      }
    }
  } catch {
    if ($RequireModule) {
      Write-Output "Required Module ExichangeOnlineManagement is not installed. Exiting Script."
      return 1;
    }
  }
}