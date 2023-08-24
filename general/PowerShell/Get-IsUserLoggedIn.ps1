# The code is refactored from "omniomi" post on the link below.
# https://superuser.com/questions/1186568/powershell-get-active-logged-in-user-in-local-machine

$userToLookfor = ""
$hasFoundUser = $false

$Users = query user 2>&1

function main() {
  $Users = $Users | ForEach-Object {
      (($_.trim() -replace ">" -replace "(?m)^([A-Za-z0-9]{3,})\s+(\d{1,2}\s+\w+)", '$1  none  $2' -replace "\s{2,}", "," -replace "none", $null))
  } | ConvertFrom-Csv



  foreach ($User in $Users) {
      $currentUser = [PSCustomObject]@{
          ComputerName = $Computer
          Username = $User.USERNAME
          SessionState = $User.STATE.Replace("Disc", "Disconnected")
          SessionType = $($User.SESSIONNAME -Replace '#', '' -Replace "[0-9]+", "")
      } 

      if ($currentUser.Username.tolower() -eq $userToLookfor.tolower()) {
        $hasFoundUser = $true
        Write-Output "User $($userToLookfor) is logged in."
        return 0;
      }
  }

  if (-not $hasFoundUser) {
    Write-Output "User is not logged in."
    return 1;
  }
}