$OldServer = '\\epic-ddms\'
$NewServer = '\\epic-dc01\'

$softRun = $false

$OldServer = $OldServer.ToLower() # Server name must start with '\\' as in '\\oldservername'
$NewServer = $NewServer.ToLower() # Server name must start with '\\' as in '\\newservername'

$driveHistory = @()

$currentLoggedInUser = Get-ItemProperty -Path HKCU:"Volatile Environment"

Write-Output "Getting the Network Drives for $($currentLoggedInUser.USERDOMAIN)\$($currentLoggedInUser.USERNAME)"

$driveMaps = Get-WmiObject win32_logicaldisk | Where-Object {$_.ProviderName -ne $null -and $_.ProviderName.ToLower() -like "$($OldServer)*" } 

Write-Output "Checking Mapped Drives"
for ($i=0; $i -lt $driveMaps.Length; $i++) {
    $currentDrive = $driveMaps[$i]
    Write-Output "Checking $($currentDrive.DeviceID)$($currentDrive.ProviderName)"

    $Name = $currentDrive.DeviceID.Replace(":", "")
    $NewRoot = $currentDrive.ProviderName.ToLower().Replace($OldServer, $NewServer)

    Write-Output "Updating drive map $($Name): $($currentDrive.ProviderName) -> $($NewRoot)"
    if (!$softRun) {
        Get-PSDrive $Name | Remove-PSDrive -Force
        New-PSDrive $Name -PSProvider FileSystem -Root $NewRoot
    }

    $driveObj = New-Object -TypeName PSObject
    $driveObj | Add-Member -MemberType NoteProperty -Name DriveLetter -Value $currentDrive.DeviceID
    $driveObj | Add-Member -MemberType NoteProperty -Name OldDriveMap -Value $currentDrive.ProviderName
    $driveObj | Add-Member -MemberType NoteProperty -Name NewDriveMap -Value $NewRoot

    $driveHistory += $driveObj
}

$desktopPath = [Environment]::GetFolderPath("Desktop")
$desktopShortcutItems = Get-Item -Path "$($desktopPath)\*.lnk"

$updatedShortcuts = @()

Write-Host "Updating Shortcut Files"
for ($i=0; $i -lt $desktopShortcutItems.Length; $i++) {
    $currentShortcutFile = $desktopShortcutItems[$i]
    
    $shell = New-Object -COM WScript.Shell
    $shortcut = $shell.CreateShortcut($currentShortcutFile)  ## Open the lnk
    
    if ($shortcut.TargetPath -like "$($OldServer)*") {
        $newTargetPath = $shortcut.TargetPath.ToLower().Replace($OldServer, $NewServer)
        $renamedOldFileName = "Old $($desktopShortcutItems[$i].name)"
        $backupFile = "$($desktopPath)\$($renamedOldFileName)"

        $shotcutObj = New-Object -TypeName PSObject
        $shotcutObj | Add-Member -MemberType NoteProperty -Name Name -Value $currentShortcutFile.name
        $shotcutObj | Add-Member -MemberType NoteProperty -Name OldPath -Value $shortcut.TargetPath
        $shotcutObj | Add-Member -MemberType NoteProperty -Name NewPath -Value $newTargetPath
        $shotcutObj | Add-Member -MemberType NoteProperty -Name BackupFile -Value $renamedOldFileName

        Write-Host "Updating desktop item: $($desktopShortcutItems[$i].name)"

        if (!$softRun) {
            Copy-Item $desktopShortcutItems[$i] $backupFile  ## Create a backup copy of the .lnk file.

            $shortcut.TargetPath =  $newTargetPath ## Make changes
            $shortcut.Save()  ## Save
        }

        $updatedShortcuts += $shotcutObj
    }

}

$driveHistory | FT -AutoSize
$updatedShortcuts | FT -AutoSize