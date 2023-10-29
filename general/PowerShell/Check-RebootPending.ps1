# Reference: https://theautomationcode.com/how-to-detect-if-a-server-reboot-is-pending/

$isRebootPending =  $true
if(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing" -Name "RebootPending" -EA Ignore) {
    $isRebootPending = $true
    Write-Output "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending is present and needing intervention."
}

if(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "RebootRequired" -EA Ignore) {
    $isRebootPending = $true
    Write-Output "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootPending is present and needing intervention."
}

if(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name "PendingFileRenameOperations" -EA Ignore){
    $isRebootPending = $true
    Write-Output "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations is present and needing intervention."
}

if($isRebootPending){
    Write-Output "Server Reboot is required"
    Write-Output "Check the registry item values mentioned."
} else {
    Write-Output "Server Reboot is not required."
}