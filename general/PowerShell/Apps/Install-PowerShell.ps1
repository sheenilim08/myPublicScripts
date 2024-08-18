param($msiInstaller="https://github.com/PowerShell/PowerShell/releases/download/v7.4.4/PowerShell-7.4.4-win-x64.msi")

function main() {
  Write-Output "Downloading $($msiInstaller)"
  Invoke-WebRequest $msiInstaller -Outfile PowerShellInstaller.msi

  Write-Output "Unblocking Installer."
  Unblock-File .\PowerShellInstaller.msi

  #$knownHashValue= "6DEFE662DD9E323113E8E683F604031D1E726615FB8E102C048FF52C6E9FD1E4"; # hashvalue for PowerShell-7.4.2-win-x64.msi - SHA256
  $knownHashValue = "C755A79759AD5DAA5F76A855ABB46BE1B9CE86616607138FEF5B02EC4BFAE643"; # hashvalue for PowerShell-7.4.4-win-x64.msi - SHA256
  $installerSHA256 = $(Get-FileHash -Path .\PowerShellInstaller.msi -Algorithm "SHA256").HASH

  if ($installerSHA256 -eq $knownHashValue) {
    #.\PowerShellInstaller.msi /qn /norestart
    Start-Process msiexec.exe -ArgumentList "/i PowerShellInstaller.msi /qn /norestart /lev ps744_install.log" -wait
    Write-Host "Installer is running in the background in silent mode."
  } else {
    Write-Host "Installer HASH did not match expected HASH value. Exiting."
  }
}

main