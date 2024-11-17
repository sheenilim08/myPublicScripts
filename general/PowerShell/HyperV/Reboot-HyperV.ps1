$checkMode = $env:checkmode_param
$documentationLnk = $env:documentationlnk_param
function preReboot {
    Write-Host "Generating list for online Hyper V VMs. <br>"
    $currentTimeDate = (get-date).ToString('MMM-dd-yyyy_HH-mm-ss')
    $preferedVmListFileName = "Reboot-HyperV_$($env:computername)_$($currentTimeDate).csv"
    
    $vms = Get-VM
    $vms | Export-Csv -Path "C:\Windows\System32\Reboot-HyperV_vmList.csv" -Force
    $vms | Export-Csv -Path "C:\Windows\System32\$($preferedVmListFileName)"

    return $vms
}

function shutdownVMs {
    param ($vms)

    Write-Host "Shutting Down VMs <br>"
    for ($i = 0; $i -lt $vms.Length; $i++) {
        Write-Host "Shutting down $($vms[$i].Name)"
        Stop-VM -Name "$($vms[$i].Name)" -Force
    }
}

function rebootHyperVHost {
    Restart-Computer
}

function postReboot {
    Write-Host "Comparing VM status to C:\Windows\System32\Reboot-HyperV_vmList.csv <br>"
    if (-not (Test-Path -Path "C:\Windows\System32\Reboot-HyperV_vmList.csv")) {
        Write-Host "The VM list file does not exist. <br>"
        Write-Host "<br>Documentation: $($documentationLnk)"
        return 1
    }

    $postRebootVMStatus = Import-Csv -Path "C:\Windows\System32\Reboot-HyperV_vmList.csv"

    $hasErrors = $false

    for ($i = 0; $i -lt $postRebootVMStatus.Length; $i++) {
        $currentVMInFile = $postRebootVMStatus[$i]

        if ($currentVMInFile.State -eq "Running") {

            try {
                Get-VM -Name "$($currentVMInFile.Name)" -ErrorAction Stop
            } catch {
                Write-Host "Failed to start VM: $($currentVMInFile.Name). <br>"
                $hasErrors = $true
            }

            Write-Host "Starting VM $($currentVMInFile.Name) <br>"
            Start-VM -Name "$($currentVMInFile.Name)"
        }
    }

    if ($hasErrors) {
        Write-Host "<br>Documentation: $($documentationLnk)"
        return 1
    }

    return 0
}

function main {
    switch($checkMode) {
        "prereboot" {
            $vms = preReboot
            shutdownVMs -vms $vms
            rebootHyperVHost

            break;
        }
        "postreboot" {
            $postRebootData = postReboot
            if ($postRebootData -eq 1) {
                exit $postRebootData
            }

            break;
        }
        default {
            Write-Host "Unknown option selected. Exiting Script."
        }
    }

    return 0
}

main