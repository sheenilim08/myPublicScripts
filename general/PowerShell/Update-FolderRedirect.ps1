param(
    $currentSrvName,
    $newSrvName
)

$serverName = $currentSrvName.ToLower()
$newServerName = $newSrvName.ToLower()

$profileFolders = Get-ItemProperty -Path HKCU:"Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$profileFolderNames = Get-ItemProperty -Path HKCU:"Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | Get-Member -MemberType NoteProperty

$currentLoggedInUser = Get-ItemProperty -Path HKCU:"Volatile Environment"

Write-Output "Currently Running this for $($currentLoggedInUser.USERDOMAIN)\$($currentLoggedInUser.USERNAME)"

$updatedFolderPaths = @()

if ($currentLoggedInUser.HOMESHARE.ToLower() -like "*$($serverName)*") {
  $newHomeShare = $currentLoggedInUser.HOMESHARE.ToLower().replace($serverName, $newServerName)
  $thisProfileFolder = New-Object -TypeName PSObject
  $thisProfileFolder | Add-Member -MemberType NoteProperty FolderName -Value "HOMESHARE"
  $thisProfileFolder | Add-Member -MemberType NoteProperty OldPath -Value $currentLoggedInUser.HOMESHARE
  $thisProfileFolder | Add-Member -MemberType NoteProperty NewPath -Value $newHomeShare

  $updatedFolderPaths += $thisProfileFolder

  Set-ItemProperty -Path HKCU:"Volatile Environment" -Name HOMESHARE -Value $newHomeShare
}

for ($i=0; $i -lt $profileFolderNames.Length; $i++) {
    $folderName = $profileFolderNames[$i].Name.ToLower()
    $folderPath = $profileFolders."$($folderName)"

    if ($folderPath -like "*$($serverName)*") {
        Write-Output "$($folderName): $($folderPath)"
        $newFolderPath = $folderPath.replace($serverName, $newServerName)

        $thisProfileFolder = New-Object -TypeName PSObject
        $thisProfileFolder | Add-Member -MemberType NoteProperty FolderName -Value $folderName
        $thisProfileFolder | Add-Member -MemberType NoteProperty OldPath -Value $folderPath
        $thisProfileFolder | Add-Member -MemberType NoteProperty NewPath -Value $newFolderPath

        $updatedFolderPaths += $thisProfileFolder

        if (![System.Boolean]::Parse($env:softrun)) {
          #Write-Output "Would have run Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders -Name $($folderName) -Value $($newFolderPath)"
          Set-ItemProperty -Path HKCU:"Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name $folderName -Value $newFolderPath
          Set-ItemProperty -Path HKCU:"Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name $folderName -Value $newFolderPath
        }
    }
}


Write-Output "Updated Folders"
$timestamp = (Get-Date).ToString("mm-dd-yyyy_hh-mm-ss")
$filename_logs = "$((pwd).Path)\folderRedirectLogs_$($timestamp).csv"

$updatedFolderPaths | Export-Csv $filename_logs
$updatedFolderPaths | FT -AutoSize

Write-Output "User $($currentLoggedInUser.USERDOMAIN)\$($currentLoggedInUser.USERNAME) will need to relogin or restart explorer.exe"
Write-Output "Logs $($filename_logs)"