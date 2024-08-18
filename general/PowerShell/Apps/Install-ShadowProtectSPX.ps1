function main() {
  Invoke-WebRequest https://downloads.storagecraft.com/SP_Files/ShadowProtect_SPX-7.5.6.win64.msi -Outfile ShadowProtect_SPX.msi
  Unblock-File .\ShadowProtect_SPX.msi
  .\ShadowProtect_SPX.msi /qn /norestart
}

main