$OldServer = '\\epic-ddms\'
$NewServer = '\\epic-dc01\'

$softRun = $false

$OldServer = $OldServer.ToLower()
$NewServer = $NewServer.ToLower()

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

    Write-Output "Name: $($Name)"
    Write-Output "NewRoot: $($NewRoot)"

    if (!$softRun) {
        Write-Output "Updating drive map $($Name): $($currentDrive.ProviderName) -> $($NewRoot)"
        Get-PSDrive $Name | Remove-PSDrive -Force -whatif
        New-PSDrive $Name -PSProvider FileSystem -Root $NewRoot -WhatIf
    }

    $driveObj = New-Object -TypeName PSObject
    $driveObj | Add-Member -MemberType NoteProperty -Name DriveLetter -Value $currentDrive.DeviceID
    $driveObj | Add-Member -MemberType NoteProperty -Name OldDriveMap -Value $currentDrive.ProviderName
    $driveObj | Add-Member -MemberType NoteProperty -Name NewDriveMap -Value $NewRoot

    $driveHistory += $driveObj
}

$driveHistory | FT -AutoSize