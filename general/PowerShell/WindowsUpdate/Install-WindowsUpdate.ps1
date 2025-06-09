# $KBNumber = $env:kbNumber
$KBNumber = $env:kbNumber

function main() {
    $winUpdateModule = Get-Module -Name PSWindowsUpdate

    if ($null -eq $winUpdateModule) {
        Install-Module -Name PSWindowsUpdate -Force
    } else {
        Update-Module -Name PSWindowsUpdate -Force
    }

    $currentExecutionPolicy = Get-ExecutionPolicy
    $tempExecuttionPolicy = "RemoteSigned"    
    if ($currentExecutionPolicy -ne "RemoteSigned" -and $currentExecutionPolicy -ne "UnRestricted") {
        Set-ExecutionPolicy -ExecutionPolicy $tempExecuttionPolicy
    }

    try {
        Get-WindowsUpdate -KBArticleID $KBNumber -Install -ErrorAction Stop
    } catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        return 1;
    }

    Set-ExecutionPolicy -ExecutionPolicy $currentExecutionPolicy

    return 0;
}

main