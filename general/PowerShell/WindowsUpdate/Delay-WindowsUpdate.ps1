param(
    $numberOfDaysToDelay=35,
    [switch]$resetWindowsUpdateStore,
    [switch]$disableWindowsUpdate
)

function main {
    $delayUntil = (Get-Date).AddDays($numberOfDaysToDelete).ToLocalTime();

    Write-Output "Setting Windows Update Delay until $($delayUntil)"
    # Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -Name 'PauseUpdatesExpiryTime' -Value $pause
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "AUOptions"

    if ($disableWindowsUpdate) {
        Write-Output "Disable Windows Update"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 1
    }

    Write-Output "Install Updates on a Saturday when Applicable"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallDay" -Value 7

    Write-Output "Install Updates on 9PM when Applicable"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "ScheduledInstallTime" -Value 21

    Write-Output "Retry Install after 60 minutes if last install fails"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "RescheduleWaitTime" -Value 60
    
    # Values Reference https://learn.microsoft.com/en-us/windows/deployment/update/waas-configure-wufb
    Write-Output "Defer Feature Updates - $($numberOfDaysToDelay) days."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdates" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays" -Value $numberOfDaysToDelay
    
    $delayQualityUpdateDays = $numberOfDaysToDelay
    if ($numberOfDaysToDelay -ge 35) {
        # Quality Updates can be delayed by 35 days only.
        $delayQualityUpdateDays = 35
    }

    Write-Output "Defer Quality Updates - $($delayQualityUpdateDays) days."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdates" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodinDays" -Value $delayQualityUpdateDays

    if ($resetWindowsUpdateStore) {
        Write-Output "Resetting Windows Update Store"
        Stop-Service -Name BITS -Force
        Stop-Service -Name CryptSvc -Force
        Stop-Service -Name wuauserv -Force

        $oldWindowsUpdateStore = "C:\Windows\SoftwareDistribution.old"
        if (Test-Path -Path $oldWindowsUpdateStore) {
            Remove-Item $oldWindowsUpdateStore -Recurse -Force
        }
        Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName $oldWindowsUpdateStore
        
        Write-Output "Start Windows Update Store"
        Start-Service -Name BITS
        Start-Service -Name CryptSvc
        Start-Service -Name wuauserv
    }
}

main