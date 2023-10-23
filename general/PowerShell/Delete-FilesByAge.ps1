param(
  [Parameter(HelpMessage="The path and file filter to delete")]
  $fileFilter = "C:\*.xml",
  
  [Parameter(HelpMessage="The minimum age to delete.")]
  $ageToDelete = 91
)

function main() {
  $filteredItems = Get-ChildItem -Path $fileFilter

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
  $quafliedForDeletion | Sort-Object Age | FT Path, Age, DateCreation -AutoSize | Out-File "C:\Scripts\DeleteJob on $($currentDate.Month)-$($currentDate.Day)-$($currentDate.Year)_$($currentDate.Hour)-$($currentDate.Minute).txt"
}

main