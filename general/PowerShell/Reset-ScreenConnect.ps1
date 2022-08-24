function Get-SCService() {
    return Get-Service -Name "ScreenConnect Client (34a68dea7e2f9bee)";
}

function main() {
    $scService = Get-SCService

    if ($scService) {
        Write-Output "Stopping ScreenConnect Service.";
        $scService | Stop-Service -Force;

        Write-Output "Starting ScreenConnect Service.";
        $scService | Start-Service;

        $scService = Get-SCService;
        if ($scService.Status -eq "Running") {
            Write-Output "ScreenConnect service is now running.";
            return 0;
        } else {
            Write-Output "ScreenConnect service was unable to start.";
            return 1;
        }

    } else {
        Write-Output "ScreenConnect Service cannot be found.";
        return 1;
    }

    return 0;
}

main