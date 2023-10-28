function main() {
  param(
    [Parameter(HelpMessage="The directory to check. Path must end '\'")]
    $directory = "C:\",
    
    [Parameter(HelpMessage="The file types to delete in the specfied directory.")]
    $ext = "*.xml",
    
    [Parameter(HelpMessage="The minimum age to delete.")]
    $ageToDelete = 91
  )

  $filteredItems = Get-ChildItem -Path "$($directory)$($ext)"

  $quafliedForDeletion = @()
  foreach ($currentItem in $filteredItems) {
    $age = (Get-Date).Subtract($currentItem.CreationTime).Days
    if ($age -ge $ageToDelete) {
      $qualifiedItem = New-object -TypeName PSObject
      $qualifiedItem | Add-Member -MemberType NoteProperty -Name "Path" -Value $currentItem.FullName
      $qualifiedItem | Add-Member -MemberType NoteProperty -Name "Age" -Value $age
      $qualifiedItem | Add-Member -MemberType NoteProperty -Name "DateCreation" -Value $currentItem.CreationTime

      $quafliedForDeletion += $qualifiedItem
    }
  }
  
  $currentDate = Get-Date
  $quafliedForDeletion | Sort-Object Age | FT Path, Age, DateCreation -AutoSize
  $quafliedForDeletion | Sort-Object Age | FT Path, Age, DateCreation -AutoSize | Out-File "$($directory)\DeleteJob on $($currentDate.Month)-$($currentDate.Day)-$($currentDate.Year)_$($currentDate.Hour)-$($currentDate.Minute).txt"


  $quafliedForDeletion | ForEach-Object {
    Remove-Item $_.Path
  }
}

main -directory "D:\BetterForms Backups\" -ext "*.xml" -ageToDelete 92