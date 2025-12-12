# This script enabled windows update UI but disables auto update, useful to environment where you want the updates on a schedule.

function setKey($path, $name, $value) {
    if (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue) {
        Set-ItemProperty -Path $path -Name $name -Value $value -Type DWORD
    }
    else {
        New-ItemProperty -Path $path -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
    }
}

function main() {
    $path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }

    $values = @{
        "DisableWindowsUpdateAccess" = 0
        "ElevateNonAdmins" = 0
        "SetDisableUXWUAccess" = 0
    }

    foreach ($name in $values.Keys) {
        $value = $values[$name]
        
        setKey -path $path -name $name -value $value
    }

    $pathAU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

    if (-not (Test-Path $pathAU)) {
        New-Item -Path $pathAU -Force | Out-Null
    }

    $valuesAU = @{
        "AUOptions" = 1
        "NoAutoUpdate" = 1
    }

    foreach ($name in $valuesAU.Keys) {
        $value = $valuesAU[$name]
        
        setKey -path $pathAU -name $name -value $value
    }

}

main