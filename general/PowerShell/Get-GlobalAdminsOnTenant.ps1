function Get-TenantIds() {
  #return Get-MsolPartnerContract -DomainName winsystems.com
  return Get-MsolPartnerContract
}

function Get-RoleUsers($tenant, $role) {
  return Get-MsolRoleMember -RoleObjectId $role.ObjectId -TenantId $tenant.TenantId
}

function main() {
  Connect-MsolService

  $outputObject = @()

  Get-TenantIds | ForEach-Object {
    
    $currentTenant = $_
    
    # Company Administrator in PowerShell is Global Administrator in the UI Portal.
    $role = Get-MsolRole -RoleName "Company Administrator" -TenantId $currentTenant.TenantId
    $roleUsers = Get-RoleUsers -tenant $currentTenant -role $role

    $roleUsers | ForEach-Object {
      $currentUser = Get-MsolUser -UserPrincipalName $_.EmailAddress -TenantId $currentTenant.TenantId

      
      $returnObject = New-Object -TypeName PSObject
      $returnObject | Add-Member -MemberType NoteProperty -Name "Tenant" -Value $currentTenant.Name
      $returnObject | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $_.DisplayName
      $returnObject | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $_.EmailAddress
      $returnObject | Add-Member -MemberType NoteProperty -Name "MFAPhoneNumber" -Value $_.StrongAuthenticationUserDetails.PhoneNumber

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

      $outputObject += $returnObject
    }
  }
  $outputObject | Sort-Object Tenant | FT Tenant, DisplayName, MFADefault, MFAState
  $outputObject | Sort-Object Tenant | Export-Csv MFAUsers.csv -Force
}

main

