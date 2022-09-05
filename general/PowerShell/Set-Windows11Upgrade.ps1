param(
    [Parameter(HelpMessage="Enable Windows 10 Upgrade")]
    $enableUpgrade = $true,

    [Parameter(HelpMessage="Version of Windows 10 you want to stay to")]
    $uptoVersion
)

function createTargetVersionKey() {
    Write-Output "Setting TargetReleaseVersion"

    $targetVersionEnabledSettingExist = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion"

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

function createTargetVersionInfoKey() {
    Write-Output "Setting the highest version that the OS can update."

    $targetVersionInfoExist = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo"

    if ($targetVersionInfoExist -eq $null) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $($uptoVersion.ToUpper()) -Type "String"
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $($uptoVersion.ToUpper()) -Type "String"
    }
}

function main() {
    $winver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion

    if ($winver -lt $uptoVersion) {
        $windownUpdateKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        if (-Not (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
            
            Write-Output "Windows Update Registry Key does not exist, Creating Key $($windownUpdateKey)"
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsUpdate" -Type "Key"
        }

        createTargetVersionKey
        createTargetVersionInfoKey
    } else {
        Write-Output "No changes applied, you are setting a version $($uptoVersion) that is currently a lower version than the running version $($winver)."
    }
}

main