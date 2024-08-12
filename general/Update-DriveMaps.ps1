# This script is for Ninja
# Ninja script must declare the following variable.
# Variable Name: input_oldservername
# Variable Name: input_newservername
# Variable Name: input_softrun

$OldServer = $env:input_oldservername
$NewServer = $env:input_newservername

$softRun = [System.Boolean]::Parse($env:input_softrun)

$OldServer = $OldServer.ToLower()
$NewServer = $NewServer.ToLower()

$driveHistory = @()

$currentLoggedInUser = Get-ItemProperty -Path HKCU:"Volatile Environment"

Write-Host "Getting the Network Drives for $($currentLoggedInUser.USERDOMAIN)\$($currentLoggedInUser.USERNAME)"

function returnMappedDrives() {
    $networkDrives = $null
    $driveCollection = @()

    if (($PSVersionTable.PSVersion.Major) -eq 2) {
        # Powershell version is 2 (Windows 7)
        $networkDrives = @(Get-WmiObject win32_logicaldisk | Where-Object { $_.ProviderName -ne $null -and $_.ProviderName.ToLower() -like "$($OldServer)*" })

        for ($i=0; $i -lt $networkDrives.Length; $i++) {
            $currentDrive = $networkDrives[$i]

            $driveObj = New-Object -TypeName PSObject
            $driveObj | Add-Member -MemberType NoteProperty -Name Name -Value $currentDrive.DeviceID.Replace(":", "");
            $driveObj | Add-Member -MemberType NoteProperty -Name DisplayRoot -Value $currentDrive.ProviderName
            
            $driveCollection += $driveObj
        }
    } else {
        # Assume Powershell version is 5 and above
        $networkDrives = @(Get-PSDrive | Where-Object {$_.DisplayRoot -ne $null -and $_.DisplayRoot.ToLower() -like "$($OldServer)*" })

        for ($i=0; $i -lt $networkDrives.Length; $i++) {
            $currentDrive = $networkDrives[$i]

            $driveObj = New-Object -TypeName PSObject
            $driveObj | Add-Member -MemberType NoteProperty -Name Name -Value $currentDrive.Name
            $driveObj | Add-Member -MemberType NoteProperty -Name DisplayRoot -Value $currentDrive.DisplayRoot
            
            $driveCollection += $driveObj
        }
    }

    return $driveCollection
}

$driveMaps = @(returnMappedDrives)
#$driveMaps = Get-WmiObject win32_logicaldisk | Where-Object { $_.ProviderName -ne $null -and $_.ProviderName.ToLower() -like "$($OldServer)*" } 
#$driveMaps = Get-WmiObject win32_logicaldisk
Write-Host "Checking Mapped Drives, Count: $($driveMaps.Count)"

for ($i=0; $i -lt $driveMaps.Length; $i++) {
    $currentDrive = $driveMaps[$i]
    Write-Host "Checking $($currentDrive.Name): $($currentDrive.DisplayRoot)"

    $Name = $currentDrive.Name
    $NewRoot = $currentDrive.DisplayRoot.ToLower().Replace($OldServer, $NewServer)

    Write-Host "Updating drive map $($Name): $($currentDrive.DisplayRoot) -> $($NewRoot)"
    if (!$softRun) {
        #Get-PSDrive -Name $Name | Remove-PSDrive -Force
        #New-PSDrive -Name $Name -PSProvider FileSystem -Root $NewRoot | Out-Null
        
        Write-Host "Remapping $($Name)"
        #net use "$($Name):" /delete /y | Out-Null
        Start-Process net.exe -ArgumentList "use $($Name): /delete /y"
        #Remove-SmbMapping "$($Name):" -Force
        #net use "$($Name): $($NewRoot)" | Out-Null
        Start-Process net.exe -ArgumentList "use $($Name): $($NewRoot) /y"
        #New-SmbMapping -LocalPath "$($Name):" -RemotePath $NewRoot
        
        Write-Host "Retarting Windows Explorer"
        Get-Process explorer | Stop-Process
        Start-Process explorer
    }

    $driveObj = New-Object -TypeName PSObject
    $driveObj | Add-Member -MemberType NoteProperty -Name DriveLetter -Value $currentDrive.Name
    $driveObj | Add-Member -MemberType NoteProperty -Name OldDriveMap -Value $currentDrive.DisplayRoot
    $driveObj | Add-Member -MemberType NoteProperty -Name NewDriveMap -Value $NewRoot

    $driveHistory += $driveObj
}

$desktopPath = [Environment]::GetFolderPath("Desktop")
$desktopShortcutItems = @(Get-Item -Path "$($desktopPath)\*.lnk")

$updatedShortcuts = @()

Write-Host "Updating Shortcut Files"
for ($i=0; $i -lt $desktopShortcutItems.Count; $i++) {
    $currentShortcutFile = $desktopShortcutItems[$i]
    
    $shell = New-Object -COM WScript.Shell
    $shortcut = $shell.CreateShortcut($currentShortcutFile.FullName)  ## Open the lnk
    
    if ($shortcut.TargetPath.ToLower() -like "$($OldServer)*") {
        $newTargetPath = $shortcut.TargetPath.ToLower().Replace($OldServer, $NewServer)
        $renamedOldFileName = "Old $($currentShortcutFile.name)"
        $backupFile = "$($desktopPath)\$($renamedOldFileName)"

        $shotcutObj = New-Object -TypeName PSObject
        $shotcutObj | Add-Member -MemberType NoteProperty -Name Name -Value $currentShortcutFile.name
        $shotcutObj | Add-Member -MemberType NoteProperty -Name OldPath -Value $shortcut.TargetPath
        $shotcutObj | Add-Member -MemberType NoteProperty -Name NewPath -Value $newTargetPath
        $shotcutObj | Add-Member -MemberType NoteProperty -Name BackupFile -Value $renamedOldFileName

        Write-Host "Updating desktop item: $($currentShortcutFile.name)"

        if (!$softRun) {
            Copy-Item $currentShortcutFile.FullName $backupFile  -Force ## Create a backup copy of the .lnk file.
            
            $shortcut.TargetPath = $newTargetPath ## Make changes
            $shortcut.Save()  ## Save
        }

        $updatedShortcuts += $shotcutObj
    }

}

Write-Host "Updated Mapped Drives"
$driveHistory | FT -AutoSize

Write-Host "Updated Shortcut Files"
$updatedShortcuts | FT -AutoSize