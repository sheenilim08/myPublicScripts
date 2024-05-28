param (
    $administrativeUnitDisplayName,
    $membersListFile,
    $groupListFile = $null
)

function Load-AzureADModule() {
    $answer = Read-Host "Required Module 'AzureAD' is not installed. Do you want to install it? (Y for yes or N for no).";
    $answer = $answer.toLower();

    if ($answer -eq 'y') {
        Write-Output "Installing AzureAD...";
        Install-Module -Name AzureAD;
        Write-Output "Install is done.";

        return $true;

    } elseif ($answer -eq 'n') {
        Write-Output "Required Module 'AzureAD' is required. Exiting Script.";
        return $false;
    }

    Write-Output "Unknown option entered. Exiting Script.";
    return $false;
}

function New-AdministrativeUnit() {
    Write-Output "Creating Administrative Unit: $($administrativeUnitDisplayName)";
    return New-AzureADMSAdministrativeUnit -DisplayName $administrativeUnitDisplayName;
}

function Add-MemberToAU($auObject, $refObjectId) {
    Add-AzureADMSAdministrativeUnitMember -Id $auObject.Id -RefObjectId $refObjectId;
}

function main() {
    Write-Output "Checking AzureAD module if installed.";
    $azModule = Get-InstalledModule AzureAd;

    if (-not $azModule) {
        if (Load-AzureADModule -eq $false) {
            Exit;
        } 
    }

    Connect-AzureAD;

    try {
        $au = New-AdministrativeUnit;
    } catch {
        Write-Output "An issue occured while creating the Azure Administraive Unit. Exiting Script.";
        Exit;
    }

    $userList = Get-Content -Path $membersListFile;

    Write-Output "`nAdding Users..."
    foreach ($upn in $userList) {
        $currentUser = Get-AzureADUser -ObjectId $upn;
        Write-Output "Adding Member ($($currentUser.DisplayName) - $($currentUser.UserPrincipalName)) to Administrative Unit.";
        Add-MemberToAU -auObject $au -refObjectId $currentUser.ObjectId;
    }
    

    if ($groupListFile) {
        Write-Output "`nAdding Groups..."
        
        $groupList = Get-Content -Path $groupListFile;
        foreach ($displayName in $groupList) {
            $currentGroup = Get-AzureADGroup -SearchString $displayName
            Write-Output "Adding Member ($($currentGroup.DisplayName) - $($currentGroup.MailNickName)) to Administrative Unit."
            Add-MemberToAU -auObject $au -refObjectId $currentGroup.ObjectId;
        }
    }

    Write-Output "Script has finished Execution."
}

main