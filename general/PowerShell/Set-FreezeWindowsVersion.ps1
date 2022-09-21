param(
    [Parameter(HelpMessage="Freeze the current OS version")]
    $enableUpgrade = $true
)

function createTargetVersionKey() {
    Write-Output "Setting TargetReleaseVersion"

    $targetVersionEnabledSettingExist = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -ErrorAction SilentlyContinue

    if ($enableUpgrade) {
        $enableTargetVersion = 1
    } else {
        $enableTargetVersion = 0
    }

    if ($targetVersionEnabledSettingExist -eq $null) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -Value $enableTargetVersion -Type "DWORD"
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -Value $enableTargetVersion -Type "DWORD"
    }
}

function createTargetVersionInfoKey($currentWinVersion) {
    Write-Output "Setting the highest version that the OS can update."

    $targetVersionInfoExist = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -ErrorAction SilentlyContinue

    if ($targetVersionInfoExist -eq $null) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $($currentWinVersion.ToUpper()) -Type "String"
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $($currentWinVersion.ToUpper()) -Type "String"
    }
}

function main() {
    $winver = $null

    if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DisplayVersion") {
        $winver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion
    } else {
        # On older Windows 10 versions this is the key that holds the version number reference
        $winver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId
    }

    if (-Not (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
        Write-Output "Windows Update Registry Key does not exist, Creating Key $($windownUpdateKey)"
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsUpdate" -Type "Key"
    }

    createTargetVersionKey
    if ($enableUpgrade) {
        createTargetVersionInfoKey -currentWinVersion $winver
    }
}

main