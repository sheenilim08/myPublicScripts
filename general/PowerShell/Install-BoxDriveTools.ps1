function main() {
  Invoke-WebRequest https://e3.boxcdn.net/box-installers/boxedit/win/currentrelease/BoxToolsInstaller-AdminInstall.msi -Outfile BoxToolsInstaller-AdminInstall.msi
  Unblock-File .\BoxToolsInstaller-AdminInstall.msi
  .\BoxToolsInstaller-AdminInstall.msi /qn /norestart
}

main