$module = Get-Module MSOnline

if ($null -eq $module) {
    Write-Host "MSOnline Module Missing in this Server/Workstation. Installing."
    Install-Module MSOnline -Force
    Write-Host "MSOnline Module Installation Complete."
}

Write-Host "Importing Module MSOnline."
Import-Module MSOnline

Write-Host "Login to your Partner Account."
Connect-MSOLService

function main() {
    $tenantIds = Get-MsolPartnerContract -All
    $tenantInfo = @()

    for ($i = 0; $i -lt $tenantIds.Count; $i++) {
        $thisTenant = Get-MsolPartnerInformation -TenantId $tenantIds[$i].TenantId
        $tenantData = New-Object -TypeName PSObject
        $tenantData | Add-Member -MemberType NoteProperty -Name "TenantId" -Value $tenantIds[$i].TenantId
        $tenantData | Add-Member -MemberType NoteProperty -Name "Name" -Value $thisTenant.PartnerCompanyName

        $tenantInfo += $tenantData
    }

    $tenantInfo | Sort-Object Name | Format-Table -AutoSize
}

main