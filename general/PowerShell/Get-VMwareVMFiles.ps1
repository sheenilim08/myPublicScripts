param (
    $vCenterName,
    $credentials
)

function IsModuleInstalled() {
    $module = Get-IsModuleInstalled -Name VMware.PowerCLI

    if ($module) {
        return $true;
    }

    return $false;
}

function main($vCenterName,$credentials) {
    if (-Not IsModuleInstalled) {
        $answer = $true

        do {
            Write-Output "A required module to run this script is not installed (VMware.PowerCLI). Do you want to install it now? (Y or N - Default)"
            $answer = Read-Host
            $answer = $answer.toLower();
        } while ($answer -ne "y" -or $answer -ne "n");

        if ($answer -eq "y") {
            Write-Output "Installing VMware.PowerCLI "
            Install-Module -Name VMware.PowerCLI
        }

        if ($answer -eq "n") {
            Write-Output "A required module (VMware.PowerCLI) is not installed. Script is now Exiting."
            Exit;
        }
    }

    Write-Output "Connecting to ESXi/vCenter $($vCenterName)"
    Connect-VIServer -Server $vCenterName -Credential $creds

    Write-Output "Retreiving all VMs managed by $($vCenterName)".
    $vms = Get-VM | Sort-Object Name

    $outputObjects = New-Object -TypeName System.Collections.ArrayList
    foreach ($vm in $vms) {
        [array]$VMhdds = $vm | Get-Harddisk
        foreach ($hdd in $VMhdds) {
            $returnObject = New-Object -TypeName System.Collections.ArrayList
            $returnObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $vm.Name
            $returnObject | Add-Member -MemberType NoteProperty -Name "VMPath" -Value $vm.ExtensionData.Config.Files.VmPathName
            $returnObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $hdd.Filename
            $returnObject | Add-Member -MemberType NoteProperty -Name "CapacityGB" -Value $hdd.CapacityGB
        }
    }
}

main -vCenterName $vCenterName -credentials $credentials