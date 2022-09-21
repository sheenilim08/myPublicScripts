param(
    [Parameter(HelpMessage="Enable Windows 10 Upgrade")]
    $enableUpgrade = $true,

    [Parameter(HelpMessage="Version of Windows you want to stay to. This must be a string.")]
    $uptoVersion,

    [Parameter(HelpMessage="Specify which Windows OS.")]
    $productVersion = "Windows 10"
)

function createProductVersionInfo() {
    if (-Not Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\ProductVersion") {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ProductVersion" -Value $productVersion -Type "String"
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ProductVersion" -Value $productVersion -Type "String"
    }
}

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

function createTargetVersionInfoKey() {
    Write-Output "Setting the highest version that the OS can update."

    $targetVersionInfoExist = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -ErrorAction SilentlyContinue

    if ($targetVersionInfoExist -eq $null) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $($uptoVersion.ToUpper()) -Type "String"
    } else {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value $($uptoVersion.ToUpper()) -Type "String"
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

    if ($winver -lt $uptoVersion) {
        $windownUpdateKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        if (-Not (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
            
            Write-Output "Windows Update Registry Key does not exist, Creating Key $($windownUpdateKey)"
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "WindowsUpdate" -Type "Key"
        }

        createTargetVersionKey
        createTargetVersionInfoKey
        createProductVersionInfo
    } else {
        Write-Output "No changes applied, you are setting a version $($uptoVersion) that is currently a lower version than the running version $($winver)."
    }
}

main