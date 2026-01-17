[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-PackageProvider `
  -Name NuGet `
  -MinimumVersion 2.8.5.201 `
  -Force `
  -Confirm:$false

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

$hostPSVersion = Get-Host

if ($hostPSVersion.Major -ne 5) {
    Write-Host "This script is only tested to work with PowerShell 5 and is observed to be having issues with other versions. If you see this message, the script might fail."
}

Enable-PSRemoting -Force

$dsmModule = Get-Module 'PSDscResources' -ErrorAction SilentlyContinue

if ($null -eq $dsmModule) {
    Write-Host "Installing PSDscResources Module"
    Install-Module -Name "PSDscResources" -Force -Confirm:$false
}

Write-Host "Importing PSDscResources Module"
Import-Module -Name "PSDscResources" -Force

Write-Host "Creating DSC Configuration"
[DSCLocalConfigurationManager()]
Configuration SetAutoCorrectMode {
    Node "localhost" {
        Settings {
            ConfigurationMode = 'ApplyAndAutoCorrect'     # Key line
            RefreshFrequencyMins = 30                     # Check for new configurations
            ConfigurationModeFrequencyMins = 15           # Enforce current config every 15 mins
        }
    }
}

Write-Host "Generating .\SetAutoCorrectMode\localhost.mof Configuration"
SetAutoCorrectMode

Write-Host "Applying .\SetAutoCorrectMode\localhost.mof Configuration."
Set-DscLocalConfigurationManager -Path .\SetAutoCorrectMode -Verbose

Write-Host "Creating DSC Configuration."
Configuration ModoNinjaService {
    Import-DSCResource -Name Service
    Node localhost
    {
        Service "Ninja RMM Service - Running" 
        {
            Name = "NinjaRMMAgent"
            StartupType = "Automatic"
            State = "Running"
        }
        
        Service "Ninja RMM Supervisor Service - Running" 
        {
            Name = "ncstreamer"
            StartupType = "Automatic"
            State = "Running"
        }
    }
}

Write-Host "Generating .\ModoNinjaService\localhost.mof Configuration"
ModoNinjaService

Write-Host "Applying .\ModoNinjaService\localhost.mof Configuration."
Start-DscConfiguration -Path .\ModoNinjaService\ -Wait -Verbose

Write-Host "DSC Configuration is applied, Windows will check Ninja Services every 15 minutes by default."