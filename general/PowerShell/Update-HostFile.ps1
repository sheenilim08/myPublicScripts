param(
    [Parameter(HelpMessage="Add Resolution?")]
    $addResolution = $true,

    [Parameter(HelpMessage="Name to Add/Remove to host file")]
    $nameToAddToHostFile,

    [Parameter(HelpMessage="IP Address to resolve the Name to.")]
    $ipToResolveNameTo
)

function main() {
    $dateTime = $(Get-Date -Format 'MM-dd-yyyy_HH-mm-ss');
    $originalHostFile = "$($env:systemroot)\system32\drivers\etc\hosts";
    $backupOfHostFile = "$($env:systemroot)\system32\drivers\etc\hosts-$($dateTime)";

    if (Test-Path -Path "$($env:systemroot)\system32\drivers\etc\hosts") {
        Write-Output "Creating a copy of '$($originalHostFile)' to '$($backupOfHostFile)'"
        Copy-Item -Path $originalHostFile -Destination $backupOfHostFile

        if ($addResolution) {
            Write-Output "Adding Name Resolution: $($ipToResolveNameTo) -> $($nameToAddToHostFile)"
            Add-Content $originalHostFile "$($ipToResolveNameTo)`t$($nameToAddToHostFile)"
        } else {
            Write-Output "Removing Name Resolution: $($ipToResolveNameTo) -> $($nameToAddToHostFile)"
            $newContent = Select-String -Path "$($originalHostFile)" -Pattern "$($ipToResolveNameTo)`t$($nameToAddToHostFile)" -NotMatch | ForEach-Object { $_.Line }
            $newContent | Set-Content -Path "$($originalHostFile)"
        }

    } else {
        Write-Output "Unable to locate the system's host file. Exiting Script."
    }
}

main