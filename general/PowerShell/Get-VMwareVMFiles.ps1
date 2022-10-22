param (
    $vCenterName,
    $credentials
)

function Check-IsModuleInstalled {
    $module = Get-InstalledModule -Name VMware.PowerCLI

    if ($module) {
        return $true;
    }

    return $false;
}

function main {
    param (
        $vCenterName, 
        $credentials
    )

    if (-not $(Check-IsModuleInstalled)) {
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

    $session = Get-PowerCLIConfiguration -Scope Session
    if ($session.InvalidCertificateAction.toString() -ne "Ignore") {
        Write-Output "Supressing Certificate Validation for the ESXi/Vcenter"
        Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false
    }

    Write-Output "Connecting to ESXi/vCenter $($vCenterName)"
    Connect-VIServer -Server $vCenterName -Credential $creds

    Write-Output "Retreiving all VMs managed by $($vCenterName)".
    $vms = Get-VM | Sort-Object Name

    $outputObjects = New-Object -TypeName System.Collections.ArrayList
    foreach ($vm in $vms) {
        [array]$VMhdds = $vm | Get-Harddisk | Sort-Object Filename
        foreach ($hdd in $VMhdds) {
            Write-Output "Retrieving HDDs for VM: $($vm.Name)"

            $returnObject = New-Object -TypeName PSObject
            $returnObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $vm.Name
            $returnObject | Add-Member -MemberType NoteProperty -Name "PowerState" -Value $vm.PowerState
            $returnObject | Add-Member -MemberType NoteProperty -Name "VMPath" -Value $vm.ExtensionData.Config.Files.VmPathName
            $returnObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $hdd.Filename
            $returnObject | Add-Member -MemberType NoteProperty -Name "CapacityGB" -Value $hdd.CapacityGB

            $outputObjects += $returnObject
        }
    }

    $fileName = "vmfiles-$(Get-Date -Format 'dddd-MM-dd-yyyy_HH-mm-ss').csv"
    Write-Output "Exporting output to $($fileName)"
    $outputObjects | Export-Csv "./$fileName"

    Write-Output "Below are all the VMfiles for all VMs managed by $($vCenterName)"
    $outputObjects | FT Name, VMPath, FileName, CapacityGB -AutoSize
    
    if ($session.InvalidCertificateAction.toString() -ne "Ignore") {
        Write-Output "Reverting Certicate Action in the current session."
        Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction $session.InvalidCertificateAction.toString() -Confirm:$false
    }
}

main -vCenterName $vCenterName -credentials $credentials