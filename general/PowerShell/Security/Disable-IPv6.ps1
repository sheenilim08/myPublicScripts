function getAllInterfaceWithIPv6 {
    Write-Host "Getting all Network Adapters with IPv6 enabled."
    return Get-NetAdapterBinding | Where-Object {$_.ComponentID -eq 'ms_tcpip6' }
}

function disableInterfaceWithIPv6 {
    param($interfaceName)

    Write-Host "Disabling IPv6 on Interface $($interfaceName)"
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID 'ms_tcpip6'
}

function main() {
    $adapters = @(getAllInterfaceWithIPv6)

    #$adapters | ForEach-Object { disableAllInterfaceWithIPv6 -interfaceName $_.Name }
    
    $modifiedInterfaces = @()

    $logFileName = "disable-ipv7-$((Get-Date).ToString('MM-dd-yyyy_HH-mm-ss')).log"
    $logDirectory = "C:\"
    $logFile = "$($logDirectory)\$($logFileName)"

    New-Item -Path $logFile -ItemType File -Force

    for ($i=1; $i -lt $adapters.Length; $i++) {
        $currentAdapter = $adapters[$i]

        $currentIntObj = New-Object -TypeName PSObject
        $currentIntObj | Add-Member -MemberType NoteProperty -Name InterfaceName -Value $currentAdapter.Name
        $currentIntObj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $currentAdapter.DisplayName
        $currentIntObj | Add-Member -MemberType NoteProperty -Name OldEnabledValue -Value $currentAdapter.Enabled

        disableInterfaceWithIPv6 -interfaceName $currentAdapter.Name | Out-File -File $logFile -Append

        $currentIntObj | Add-Member -MemberType NoteProperty -Name NewEnabledValue -Value $false

        $modifiedInterfaces += $currentIntObj
    }

    Write-Output "Updated Interfaces, log file: $($logFile)"
    $modifiedInterfaces | FT -AutoSize
    $modifiedInterfaces | FT -AutoSize | Out-File -File $logFile -Append
}

main