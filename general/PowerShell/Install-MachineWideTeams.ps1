# See versions on https://learn.microsoft.com/en-us/officeupdates/teams-app-versioning

$version = "1.5.00.36367";
#$url = "https://statics.teams.cdn.office.net/production-windows-x64/$($version)/Teams_windows_x64.exe"
$url = "https://statics.teams.cdn.office.net/production-windows-x64/1.5.00.36367/Teams_windows_x64.msi"

Write-Output "Downloading Teams Installer"
Write-Output "URL $($url)";
Invoke-WebRequest $url -o Teams_windows_x64.msi

Write-Output "Installing Teams $($version)"
msiexec /i .\Teams_windows_x64.msi /qn /norestart
Write-Output "Installation Complete"
