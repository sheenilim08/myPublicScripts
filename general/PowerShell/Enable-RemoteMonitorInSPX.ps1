function main() {
    if (Test-Path -Path "C:\Program Files\StorageCraft\spx\spx_cli.exe") {
        Write-Output "Enabling Remote Access via port 13581."
        Set-Location "C:\Program Files\StorageCraft\spx";
        .\spx_cli.exe remote --enable 13581
    } else {
        Write-Output "Unable to locate spx_cli.exe. Exiting Script."
    }
}

main