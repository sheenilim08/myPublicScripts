param($folderPath)

$inaccessibleFolders = @()

#Get-ChildItem -Path $folderPath -Directory | ForEach-Object {
$childFolders = Get-ChildItem -Path $folderPath -Directory -Recurse | Sort-Object FullName
foreach ($currentFolder in $childFolders) {
    try {
        New-Item -Path $currentFolder.FullName -Name "testfile.txt" -Force -ItemType File -ErrorAction Stop
        Remove-Item -Path "$($currentFolder.FullName)\testfile.txt"
    } catch {
        $thisFolder = New-Object -TypeName Object
        $thisFolder | Add-Member -MemberType NoteProperty -Name "Path" -Value $currentFolder.FullName
        $inaccessibleFolders += $thisFolder
    }
}

if ($inaccessibleFolders.Count -eq 0) {
    Write-Output "There are no folders that you cannot access."
}

Write-Output "Inaccessible Folders"
$inaccessibleFolders | FT -AutoSize -Wrap