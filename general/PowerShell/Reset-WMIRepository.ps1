Write-Output "Chaning location to C:\Windows\System32\wbem\"
Set-Location -Path "C:\Windows\System32\wbem\"

$mofFiles = Get-ChildItem -Path ".\*.mof"
for ($i = 0; $i -lt $mofFiles.Length; $i++) {
    Write-Output "Processing: $($mofFiles[$i].Name)"
    Start-Process -FilePath ".\mofcomp.exe" -ArgumentList $mofFiles[$i].Name
}

$mofFiles2 = Get-ChildItem -Path ".\en-us\*.mof"
for ($i = 0; $i -lt $mofFiles2.Length; $i++) {
    Write-Output "Processing: $($mofFiles[$i].Name)"
    Start-Process -FilePath ".\mofcomp.exe" -ArgumentList $mofFiles2[$i].Name
}