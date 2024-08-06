$OldServer = '\\epic-ddms\'
$NewServer = '\\epic-dc01\'

$softRun = $false

$OldServer = $OldServer.ToLower()
$NewServer = $NewServer.ToLower()

$driveHistory = @()
 
Get-WmiObject win32_logicaldisk | Where-Object {$_.ProviderName -ne $null -and $_.ProviderName.ToLower() -like "$($OldServer)*" } | ForEach-Object { 
    $Name = (($_.DeviceID) -replace ":", "")
    $NewRoot = $_.ProviderName.ToLower().Replace($OldServer, $NewServer)

    Write-Output "Name: $($Name)"
    Write-Output "NewRoot: $($NewRoot)"

    if (!$softRun) {
        Write-Output "Updating drive map $($Name): $($_.ProviderName) -> $($NewRoot)"
        Get-PSDrive $Name | Remove-PSDrive -Force -whatif
        New-PSDrive $Name -PSProvider FileSystem -Root $NewRoot -WhatIf
    }

    $driveObj = New-Object -TypeName PSObject
    $driveObj | Add-Member -MemberType NoteProperty -Name DriveLetter -Value $_.DeviceID
    $driveObj | Add-Member -MemberType NoteProperty -Name OldDriveMap -Value $_.ProviderName
    $driveObj | Add-Member -MemberType NoteProperty -Name NewDriveMap -Value $NewRoot

    $driveHistory += $driveObj
}

$driveHistory