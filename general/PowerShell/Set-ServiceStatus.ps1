$input_serviceName = $env:serviceName
$input_disableService = [System.Boolean]::Parse($env:disableService)
$input_stopService = [System.Boolean]::Parse($env:stopService)

function main {
    try {
        $thisService = Get-Service -Name $input_serviceName -ErrorAction Stop
    } catch {
        Write-Output "Service $($thisService.Name) is not found."
        return 1 # Error code
    }

    if ($input_disableService) {
        Write-Output "Disabling Service $($thisService.Name)"
        Set-Service -Name $thisService.Name -StartupType Disabled
    }

    if ($input_stopService) {
        Write-Host "Stopping Service $($thisService.Name)"
        Stop-Service -Name $thisService.Name -Force
    }

    return 0
}

main