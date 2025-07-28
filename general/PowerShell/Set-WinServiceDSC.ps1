$dsmModule = Get-Module 'PSDscResources' -ErrorAction SilentlyContinue

if ($null -eq $dsmModule) {
    Write-Host "Installing PSDscResources Module"
    Install-Module -Name "PSDscResources" -Force
}

Import-Module -Name "PSDscResources" -Force

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