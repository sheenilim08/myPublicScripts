function main {
    $lastBootTime = (Get-Date) – (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

    # I am hoping that this script has been executed by the RMM
    # RMM should run this script around 15 minutes
    if ($lastBootTime.TotalMinutes -lt 20) {
        Write-Output "This endpoint has been up for more than 20 minutes, no action is required." 
        return 0
    }

    $installedApps = Get-WmiObject -Class Win32_Product -Filter "(Name LIKE '%Sentinel%' AND Version LIKE '24%') OR (Name LIKE '%ShadowProtect SPX%')"

    if ($installedApps.Count -eq 2) {
        Write-Output "Attaching SPX Snapshot Driver (stcvsm.sys)."
        try {
            Start-Process ftlmc -ArgumentList "attach stcvsm C:"
            return 0
        } catch {
            Write-Output "An issue occured while attaching the SPX Snapshot Driver (stcvsm.sys)."
            return 2
        }
    } 
}

return main