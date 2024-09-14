param(
    [string]
    $dnsIPsToAdd,
    [boolean]
    $softrun,
    [boolean]
    $replace
)

function Get-ActiveNetworkInterfaces {
    return Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
}

function Get-IsNetAdapterConfiguredWithGateway {
    param($interfaceIndex)

    $thisNIC = Get-NetIPConfiguration -InterfaceIndex $interfaceIndex -Detailed
    if ($null -ne $thisNIC.IPv4DefaultGateway) {
        return @{
            success=$true
            data=$thisNIC
        }
    }

    return @{
        success=$false
    };
}

function main {
    $additionalDNSIPs = @($dnsIPsToAdd.Replace(" ","").Split(",")); 
    $activeAdapters = @(Get-ActiveNetworkInterfaces)

    for($i=0; $i -lt $activeAdapters.Length; $i++) {
        $nicAdapter = Get-IsNetAdapterConfiguredWithGateway -interfaceIndex $activeAdapters[$i].InterfaceIndex

        if ($nicAdapter.success) {
            $newDnsServerAddressList = @()
            if (!$replace) {
                $newDnsServerAddressList = $nicAdapter.data.DNSServer[1].ServerAddresses # add the current DNS Server Address List
                for ($j=0; $j -lt $additionalDNSIPs.Length; $j++) {
                    $newDnsServerAddressList += $additionalDNSIPs[$j];
                }
            } else {
                $newDnsServerAddressList = $additionalDNSIPs
            }
            
            if (!$softrun) {
                Write-Host "Updating Interface $($nicAdapter.data.InterfaceAlias) - $($nicAdapter.data.InterfaceIndex)."
                Set-DnsClientServerAddress -InterfaceIndex $nicAdapter.data.InterfaceIndex -ServerAddresses $newDnsServerAddressList
            } else {
                Write-Host "Would have updated Interface '$($nicAdapter.data.InterfaceAlias)' - Index: '$($nicAdapter.data.InterfaceIndex)'"
            }
            
            Write-Host "Old Interface DNS Server Address: `n$($nicAdapter.data.DNSServer[1].ServerAddresses)"
            Write-Host "New Interface DNS Server Address: `n$($newDnsServerAddressList)`n`n"
        }
    }
}

main