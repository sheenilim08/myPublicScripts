param(
  [Parameter(HelpMessage="CSV file that contains the groups to be created.")]
  $OUDN
  )

function isADModuleIsInstalled() {
  return Get-Module -ListAvailable -Name ActiveDirectory
}

function main() {
  $csvFile = Import-Csv -LiteralPath $OUDN

  try {
    if (-not (isADModuleIsInstalled)) {
      Write-Output "Module 'ActiveDirectory is not installed, attemping to install'"
      Install-Module ActiveDirectory
    }
  } catch {
    Write-Output "An error occured while Installing the 'ActiveDirectory' Module. Exiting Script."
    return;
  }

  try {
    Write-Output "Importing 'ActiveDirectory' Module"
    Import-Module ActiveDirectory
  } catch { 
    Write-output "An Error occured while Importing the 'ActiveDirectory' Module. Exiting Script."
    return;
  }

  foreach ($companyLine in $csvFile) {
    Write-Output "Creating group for $($companyLine.GroupName)"

    New-ADGroup -Path $companyLine.OUDN -Name $companyLine.GroupName -DisplayName $companyLine.GroupName -SamAccountName $companyLine.SamAccountName -Description $companyLine.GroupDescription -GroupCategory $companyLine.GroupType -GroupScope $companyLine.GroupScope

    Set-ADGroup -Identity $companyLine.GroupName -Replace @{info="$($companyLine.Notes)"}
  }

  # Write-Output $csvFile
}

$ErrorActionPreference = 'Stop';
main