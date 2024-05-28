# Download links
# https://helpx.adobe.com/acrobat/kb/acrobat-dc-downloads.html

function main() {
  Write-Output "Downloading Installer"
  if ([System.Environment]::Is64BitProcess) {
    Invoke-WebRequest https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip -Outfile AdobeStdInstaller.zip
  } else {
    Invoke-WebRequest https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_WWMUI.zip -Outfile AdobeStdInstaller.zip
  }

  Unblock-File .\AdobeStdInstaller.zip

  Write-Output "Unpacking zip file"
  New-item -ItemType "Directory" -Path "AdobeStdInstaller"
  Expand-Archive -Path .\AdobeStdInstaller.zip

  Write-Output "Starting silent install."
  Set-Location '.\AdobeStdInstaller\Adobe Acrobat\'
  .\setup.exe /sPB /rs

  do {
    Start-Sleep -Seconds 30
    $setupProcess = Get-Process setup
    Write-Output "Setup is still running in the background. $((get-date).ToString('MMM-dd-yyyy_HH-mm-ss'))"
  } while ($null -ne $setupProcess)

  Write-Output "Install is complete."
  Write-Output "NOTE: The setup by default will run in the background, so the script may finish before the actual install will complete. Look for setup.exe process if it still running."
}

main