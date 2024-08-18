function main() {
  Invoke-WebRequest https://e3.boxcdn.net/desktop/releases/win/BoxDrive.msi -Outfile BoxDrive.msi
  Unblock-File .\BoxDrive.msi
  .\BoxDrive.msi /qn /norestart
}

main