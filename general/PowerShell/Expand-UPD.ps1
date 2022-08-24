param(
    [Parameter(HelpMessage="The User virtual disk path.")]
    $vDiskPath, 

    [Parameter(HelpMessage="The size you want to expand it to.")]
    $newSizeInGB, 

    [Parameter(HelpMessage="Use the unallocated space on the virtual disk after its expanded. This is false by default.")]
    $expandUnallocated = $false
)

function main() {
    if (-not $(Test-Path -Path $vDiskPath)) {
        Write-Output "The virtual disk '$($vDiskPath)' does not exist. Exiting Script."
    }
    
    $userVirtualDisk = Get-VHD -Path $vDiskPath
    $userVDiskInGB = $($userVirtualDisk.Size/1GB;
    if ($($userVDiskInGB) -ge $newSizeInGB) {
        Write-Output "The current size of the virtual disk is greater than or equal to the new requested size. Exiting Script."
        Exit;
    }

    try {
        Resize-VHD -Path $vDiskPath -SizeBytes $newSizeInGB
    } catch {
        Write-Output "An issue occured while expanding the virtual disk $($vDiskPath)."
    }
}

main