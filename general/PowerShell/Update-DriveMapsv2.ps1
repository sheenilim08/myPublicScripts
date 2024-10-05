$OldServer = $env:input_oldserver
$NewServer = $env:input_newservername

$softRun = [System.Boolean]::Parse($env:softrun_param)
$mappedDrivesOnly = [System.Boolean]::Parse($env:mappeddrives_param)
$desktopShortCutsOnly = [System.Boolean]::Parse($env:desktopshortcuts_param)
$printersOnly = [System.Boolean]::Parse($env:remapprinters_param)
$removeOldPrinterMappings = [System.Boolean]::Parse($env:removeoldprinters_param)

$OldServer = $OldServer.ToLower()
$NewServer = $NewServer.ToLower()

$driveHistory = @()

$currentLoggedInUser = Get-ItemProperty -Path HKCU:"Volatile Environment"


function returnMappedDrives() {
    $networkDrives = $null
    $driveCollection = @()

    if (($PSVersionTable.PSVersion.Major) -eq 2) {
        # Powershell version is 2 (Windows 7)
        $networkDrives = @(Get-WmiObject win32_logicaldisk | Where-Object {$null -ne $_.ProviderName -and $_.ProviderName.ToLower() -like "$($OldServer)*" })

        for ($i=0; $i -lt $networkDrives.Length; $i++) {
            $currentDrive = $networkDrives[$i]

            $driveObj = New-Object -TypeName PSObject
            $driveObj | Add-Member -MemberType NoteProperty -Name Name -Value $currentDrive.DeviceID.Replace(":", "");
            $driveObj | Add-Member -MemberType NoteProperty -Name DisplayRoot -Value $currentDrive.ProviderName
            
            $driveCollection += $driveObj
        }
    } else {
        # Assume Powershell version is 5 and above
        $networkDrives = @(Get-PSDrive | Where-Object {$null -ne $_.DisplayRoot -and $_.DisplayRoot.ToLower() -like "$($OldServer)*" })

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

if ($mappedDrivesOnly) {
    Write-Host "Getting the Network Drives for $($currentLoggedInUser.USERDOMAIN)\$($currentLoggedInUser.USERNAME)"
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
            Write-Host "Remapping $($Name)"
            Start-Process net.exe -ArgumentList "use $($Name): /delete /y"
            Start-Process net.exe -ArgumentList "use $($Name): $($NewRoot) /y"
            
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

    Write-Host "Updated Mapped Drives"
    $driveHistory | Format-Table -AutoSize
}

if ($desktopShortCutsOnly) {
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

    Write-Host "Updated Shortcut Files"
    $updatedShortcuts | Format-Table -AutoSize
}

if ($printersOnly) {
    $mappedPrinters = @(Get-Printer -Name "$($OldServer)\*")

    $newMappedPrinters = @()
    for ($i=0; $i -lt $mappedPrinters.Length; $i++) {
        $newMappedPrinterPath = $mappedPrinters[$i].Name.ToLower().Replace($OldServer.ToLower(), $NewServer.ToLower())

        if (!$softRun) {
            Write-Host "Adding New Printer Mapping $($newMappedPrinterPath)"
            Add-Printer -ConnectionName $newMappedPrinterPath

            if ($removeOldPrinterMappings) {
                Write-Host "Removing Old Printer Mapping $($mappedPrinters[$i].Name)"
                Remove-Printer -Name $mappedPrinters[$i].Name
            }
        }

        $newMappedPrinter = New-Object -TypeName PSObject
        $newMappedPrinter | Add-Member -MemberType NoteProperty -Name OldMappedPrinter -Value $mappedPrinters[$i].Name
        $newMappedPrinter | Add-Member -MemberType NoteProperty -Name NewMappedPrinter -Value $newMappedPrinterPath
        $newMappedPrinter | Add-Member -MemberType NoteProperty -Name IsOldPrinterMapRemoved -Value $removeOldPrinterMappings
        $newMappedPrinters += $newMappedPrinter
    }

    Write-Host "Added Printer Mappings"
    $newMappedPrinters | Format-Table OldMappedPrinter, NewMappedPrinter, IsOldPrinterMapRemoved -AutoSize
}