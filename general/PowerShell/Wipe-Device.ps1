$isWinREDisabled = (reagentc /info | find "Windows RE status").Contains("Disabled")

if ($isWinREDisabled) {
    Write-Output "regagentc /info shows WinRE disabled. Exiting script. Wipe will not be performed."
    exit 1
}

$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_RemoteWipe"
$methodName = "doWipeProtectedMethod"

$session = New-CimSession

$params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
$param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", "", "String", "In")
$params.Add($param)

try {
    Write-Host "Starting Device Wipe."
    $instance = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "ParentID='./Vendor/MSFT' and InstanceID='RemoteWipe'"
    $session.InvokeMethod($namespaceName, $instance, $methodName, $params)
    Write-Host "Device Wipe command sent."

    exit 0
} catch {
    Write-Host "An error occured while performing the device wipe. "
    exit 2
}