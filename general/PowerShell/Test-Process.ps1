# accepts the process name to monitor without the extention
# Example: To monitoring explorer.exe, processname input value should be "explorer"
param(
    [string]
    $processname,
    [string[]]
    $servernames
)
function main {
    $process = Get-Process -Name $processname -ErrorAction SilentlyContinue
    $monitoredServerNames = $servernames.ToLower()

    $currentServerName = ($env:COMPUTERNAME).ToLower()
    if ($monitoredServerNames.ToLower().Contains($currentServerName)) {
        if ($null -eq $process) {
            Write-Host "[Error] The process $($processname) is not running."
            return 2;
        }
    }

    Write-Host "[Successful] The script has finished running."
    return 0;
}

main