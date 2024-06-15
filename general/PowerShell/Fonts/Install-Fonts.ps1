# Credits
# The script is a variant copy of the post in https://stackoverflow.com/questions/77829662/a-powershell-script-to-install-fonts-on-windows-11

param($fontToInstallLocation)

$fontls = Get-ChildItem -Path "$($fontToInstallLocation)\*" -Include ('*.fon','*.otf','*.ttc','*.ttf')

foreach ($currentFont in $fontls) {
  Write-Host 'Installing font -' $currentFont.BaseName

  Copy-Item $currentFont "C:\Windows\Fonts"

  #register font for all users
  New-ItemProperty -Name $currentFont.BaseName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $currentFont.name
}