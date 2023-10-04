function Get-TenantIds() {
  #return Get-MsolPartnerContract -DomainName tenantPrimaryDomain.com
  return Get-MsolPartnerContract
}

function Get-RoleUsers($tenant, $role) {
  return Get-MsolRoleMember -RoleObjectId $role.ObjectId -TenantId $tenant.TenantId -MemberObjectTypes "User"
}

function main() {
  if ((host).Version.Major -lt 7) {
    Write-Output "This script uses the Microsoft.Graph module which requires PowerShell version 7. Your PowerShell version is $(host).Version."
    $answer = Read-Host "Do you want to install PowerShell? [Y/N]"
    if ($answer -eq "Y" -or $answer -eq "y") {
      winget install --id Microsoft.Powershell --source winget

      Write-Output "The new version of Powershell is installed, re-run this script using the new Powershell. Exiting."
    }
    exit;
  }

  Write-Output "Installing MSOnline"
  if (Get-Module -ListAvailable -Name MSOnline) {
    Write-Output "MSOnline module is installed."
  } else {
    Write-Output "MSOnline module is not installed. Installing."
    Install-Module -Name MSOnline
  }
  Import-Module -Name MSOnline

  Write-Output "Installing MSOnline Microsoft.Graph."
  if (Get-Module -ListAvailable -Name Microsoft.Graph) {
    Write-Output "Microsoft.Graph module is installed."
  } else {
    Write-Output "Microsoft.Graph module is not installed. Installing."
    Install-Module -Name Microsoft.Graph
  }
  Import-Module Microsoft.Graph

  Connect-MsolService

  $outputObject = @()

  Get-TenantIds | ForEach-Object {
    
    $currentTenant = $_
    Write-Output "Currently Checking Tenant $($_.Name)"

    # Company Administrator in PowerShell is Global Administrator in the UI Portal.
    $role = Get-MsolRole -RoleName "Company Administrator" -TenantId $currentTenant.TenantId
    $roleUsers = Get-RoleUsers -tenant $currentTenant -role $role

    Connect-MgGraph -Scopes Policy.ReadWrite.ConditionalAccess, Policy.Read.All
    $secDefaultsEnabled = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy | select IsEnabled

    $roleUsers | ForEach-Object {
      $currentUser = Get-MsolUser -Objectid $_.ObjectId -TenantId $currentTenant.TenantId
      
      $returnObject = New-Object -TypeName PSObject
      $returnObject | Add-Member -MemberType NoteProperty -Name "Tenant" -Value $currentTenant.Name
      $returnObject | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $currentUser.DisplayName

      $returnObject | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $currentUser.UserPrincipalName
      $returnObject | Add-Member -MemberType NoteProperty -Name "MFAPhoneNumber" -Value $currentUser.StrongAuthenticationUserDetails.PhoneNumber

      $returnObject | Add-Member -MemberType NoteProperty -Name "SecurityDefaultsEnabled" -Value $secDefaultsEnabled

      # Get Default MFA Method
      # Reference: https://www.alitajran.com/export-office-365-users-mfa-status-with-powershell/
      $mfaDefaultMethod = ($currentUser.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq "True" }).MethodType
      if ($mfaDefaultMethod) {
        switch ($mfaDefaultMethod) {
            "OneWaySMS" { $mfaDefaultMethod = "Text code authentication phone" }
            "TwoWayVoiceMobile" { $mfaDefaultMethod = "Call authentication phone" }
            "TwoWayVoiceOffice" { $mfaDefaultMethod = "Call office phone" }
            "PhoneAppOTP" { $mfaDefaultMethod = "Authenticator app or hardware token" }
            "PhoneAppNotification" { $mfaDefaultMethod = "Microsoft authenticator app" }
        }
      }
      $returnObject | Add-Member -MemberType NoteProperty -Name "MFADefault" -Value $mfaDefaultMethod

      if ($_.StrongAuthenticationRequirements) {
        $returnObject | Add-Member -MemberType NoteProperty -Name "MFAState" -Value $_.StrongAuthenticationRequirements.State
      } else {
        $returnObject | Add-Member -MemberType NoteProperty -Name "MFAState" -Value "Disabled"
      }

      $returnObject | Add-Member -MemberType NoteProperty -Name "AccountDisabled" -Value $currentUser.BlockCredential

      $outputObject += $returnObject
    }
  }
  $outputObject | Sort-Object Tenant | FT Tenant, DisplayName, MFADefault, MFAState
  $outputObject | Sort-Object Tenant | Export-Csv MFAUsers.csv -Force
}

main