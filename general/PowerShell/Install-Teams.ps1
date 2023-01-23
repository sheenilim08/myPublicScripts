$version = "1.5.00.36367";
$url = "https://statics.teams.cdn.office.net/production-windows-x64/$($version)/Teams_windows_x64.exe"

Write-Output "Downloading Teams Installer"
Write-Output "URL $($url)";
Invoke-WebRequest $url -o Teams_windows_x64.exe

Write-Output "Installing Teams $($version)"
.\Teams_windows_x64.exe -s
Write-Output "Installation Complete"
