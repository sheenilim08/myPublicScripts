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
  $message = "For documentation, please refer to the link below. `n`nhttps://modo-networks-llc.itglue.com/2416831/docs/14243804 `n`n"
  $message += $quafliedForDeletion | Sort-Object Age | FT Path, Age, DateCreation -AutoSize | Out-String
  Write-Output $message
  $message | Out-File "$($directory)\DeleteJob on $($currentDate.Month)-$($currentDate.Day)-$($currentDate.Year)_$($currentDate.Hour)-$($currentDate.Minute).txt"


  $quafliedForDeletion | ForEach-Object {
    Remove-Item $_.Path
  }
}

main -directory "D:\BetterForms Backups\" -ext "*.xml" -ageToDelete 91