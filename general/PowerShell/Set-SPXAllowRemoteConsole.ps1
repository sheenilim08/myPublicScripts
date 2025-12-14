function main() {
  $RuleName = "Allow StorageCraft SPX Remote Service Port 13581"
  $ProgramPath = "C:\Program Files\StorageCraft\spx\spx_service.exe"
  $Port = 13581
  
  if (Test-Path -Path "C:\Program Files\StorageCraft\spx\spx_cli.exe") {
    Write-Output "Enabling Remote Access via port 13581."
    Set-Location "C:\Program Files\StorageCraft\spx";
    .\spx_cli.exe remote --enable 13581
    
    
    if (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue) {
      Write-Host "Firewall rule $RuleName exist. Updating Rule."
      
      Set-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction Inbound `
        -Program $ProgramPath `
        -Protocol TCP `
        -LocalPort $Port `
        -Action Allow `
        -Profile Any `
        -Enabled True
    }
    else {
      New-NetFirewallRule `
        -DisplayName $RuleName `
        -Direction Inbound `
        -Program $ProgramPath `
        -Protocol TCP `
        -LocalPort $Port `
        -Action Allow `
        -Profile Any `
        -Enabled True
  
      Write-Host "Firewall rule created: $RuleName"
    }
  } else {
      Write-Output "Unable to locate spx_cli.exe. Exiting Script."
  }
}

main