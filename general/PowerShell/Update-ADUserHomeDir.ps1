param(
    $inputCsv = "inputfile.csv",
    $outputCsv = "outputfile.csv",
    [switch]$softRun
)

Import-Module ActiveDirectory

function main {
    Write-Output "Importing $($inputCsv)"
    $fileData = Import-Csv -Path $inputCsv

    $outputObj = @()
    $erroredAccounts = @()

    for ($i = 0; $i -lt $fileData.length; $i++) {
        try {
            $currenADUser = Get-ADUser -Identity $fileData[$i].samaccountname -Properties UserPrincipalName, samAccountName, DisplayName, HomeDirectory, HomeDrive

            Write-Output "Updating $($currenADUser.DisplayName) OldHomeDir:$($currenADUser.homedirectory), NewHomeDir:$($fileData[$i].newhomedirectory)"

            $processedADUser = New-Object -TypeName PSObject
            $processedADUser | Add-Member -MemberType NoteProperty -Name "Old Home Dir" -Value $currenADUser.homedirectory 
            $processedADUser | Add-Member -MemberType NoteProperty -Name "New Home Dir" -Value $fileData[$i].newhomedirectory
            $processedADUser | Add-Member -MemberType NoteProperty -Name "Home Drive" -Value $fileData[$i].homedrive
            $processedADUser | Add-Member -MemberType NoteProperty -Name "samAccoutnName" -Value $fileData[$i].samAccountName
            $processedADUser | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $fileData[$i].UserPrincipalName
            $processedADUser | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $fileData[$i].DisplayName
            $processedADUser | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $fileData[$i].Enabled

            if (!$softRun) {
                Write-Output "Would have run Set-ADUser for $($fileData[$i].samaccountname)"
                Set-ADUser -Identity $currenADUser.Identity -HomeDirectory $fileData[$i].newhomedirectory
            }

            $outputObj += $processedADUser
        } catch {
            $errorAccount = New-Object -TypeName PSObject
            $errorAccount | Add-Member -MemberType NoteProperty -Name "New Home Dir" -Value $fileData[$i].newhomedirectory
            $errorAccount | Add-Member -MemberType NoteProperty -Name "Home Directory" -Value $fileData[$i].homedirectory
            $errorAccount | Add-Member -MemberType NoteProperty -Name "Home Drive" -Value $fileData[$i].homedrive
            $errorAccount | Add-Member -MemberType NoteProperty -Name "samAccoutnName" -Value $fileData[$i].SamAccountName
            $errorAccount | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $fileData[$i].userprincipalname
            $errorAccount | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $fileData[$i].DisplayName
            $errorAccount | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $fileData[$i].enabled

            $erroredAccounts += $errorAccount
        }
    }

    Write-Output "Exporting Processed AD Users."
    $outputObj | Export-Csv $outputCsv

    Write-Output "Errored Accoutns"
    $erroredAccounts | Export-Csv "ErroredAccoutns-$($outputCsv)"
    $erroredAccounts | FT -AutoSize
}

main