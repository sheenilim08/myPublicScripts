param(
    [Parameter(HelpMessage="The path where the UPD's are located")]
    $updFolderPath 
)

function main() {
    Import-Module ActiveDirectory

    try {
        $vhdxs = Get-ChildItem -Path $updFolderPath | Sort-Object LastWriteTime
    } catch {
        Write-Output "There was an issue trying to retrieve the VHDX files. Exiting script."
        Exit;
    }

    $outputItems = New-Object -TypeName System.Collections.ArrayList
    $notExistingUser = New-Object -TypeName System.Collections.ArrayList

    foreach ($vhdxFile in $vhdxs) {
        $currentVHDObject = Get-VHD -Path $($vhdxFile).FullName
        try {
            $user = $(Get-ADUser -Identity $($vhdxFile.Name).ToLower().Replace("uvhd-","").Replace(".vhdx",""))
        } catch {
            Write-Output "Unable to locate a user with SID value '$($user)'"
            $notExistingUser += $($vhdxFile).FullName
            Continue
        }

        $currentObject = New-Object -TypeName PSObject
        $currentObject | Add-Member -NotePropertyName LastWriteTime -NotePropertyValue $($vhdxFile.LastWriteTime)
        $currentObject | Add-Member -NotePropertyName User -NotePropertyValue $user.Name
        $currentObject | Add-Member -NotePropertyName VHDFileName -NotePropertyValue $($vhdxFile.FullName)
        $currentObject | Add-Member -NotePropertyName AllocatedSizeInGB -NotePropertyValue $($currentVHDObject.Size/1GB)
        $currentObject | Add-Member -NotePropertyName FileActualSizeInGB -NotePropertyValue $($currentVHDObject.FileSize/1GB)

        $outputItems += $currentObject
    }
    Write-Output "Mapped VHDX and Users"
    $outputItems | Export-Csv MappedVHDXandUsers.csv
    $outputItems | FT LastWriteTime, User, VHDFileName, AllocatedSizeInGB, FileActualSizeInGB -AutoSize

    Write-Output "Potentially Orphanned Files"
    $outputItems | Export-Csv PotentiallOrphannedFiles.csv
    $notExistingUser | FT FullName

    
}

main