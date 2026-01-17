# This script only updates Chrome (Computer Install) and Edge .
# User based chrome is not yet supported by this script.

$currentChromeVersion = (Get-Item "C:\Program Files\Google\Chrome\Application\chrome.exe").VersionInfo.ProductVersion
Write-Output "Current Chrome version (Computer Install) Before Update $($currentChromeVersion)"
Start-Process -FilePath "C:\Program Files (x86)\Google\Update\GoogleUpdate.exe" -ArgumentList "/ua","/installsource","scheduler"
$currentChromeVersion = (Get-Item "C:\Program Files\Google\Chrome\Application\chrome.exe").VersionInfo.ProductVersion
Write-Output "Current Chrome version (Computer Install) After Update $($currentChromeVersion) - Might need to Restart after ugprade (if there is any)"

# loop through profiles for user based chrome update
# (Get-Item "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe").VersionInfo.ProductVersion

$currentEdgeVersion = (Get-Item "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion
Write-Output "Current Edge version (Computer Install) Before Update $($currentEdgeVersion)"
Start-Process -FilePath "C:\Program Files (x86)\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" -ArgumentList "/ua","/installsource","scheduler"
Write-Output "Current Edge version (Computer Install) After Update $($currentEdgeVersion) - Might need to Restart after ugprade (if there is any)"

# loop through profiles for user based chrome update
# (Get-Item "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe").VersionInfo.ProductVersion

