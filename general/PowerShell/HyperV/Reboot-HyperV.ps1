$checkMode = $env:checkmode_param

function preReboot {
    Write-Output "Generating list for online Hyper V VMs."
    $currentTimeDate = (get-date).ToString('MMM-dd-yyyy_HH-mm-ss')
    $preferedVmListFileName = "Reboot-HyperV_$($env:computername)_$($currentTimeDate).csv"
    
    $vms = Get-VM
    $vms | Export-Csv -Path "C:\Windows\System32\Reboot-HyperV_vmList.csv" -Force
    $vms | Export-Csv -Path "C:\Windows\System32\$($preferedVmListFileName)"    
}

function shutdownVMs {
    Write-Output "Shutting Down VMs"
    for ($i = 0; $i -lt $vms.Length; $i++) {
        Write-Output "Shutting down $($vms[$i].Name)"
        Stop-VM -Name "$($vms[$i].Name)" -Force
    }
}

function rebootHyperVHost {
    Restart-Computer
}

function postReboot {
    Write-Output "Comparing VM status to C:\Windows\System32\Reboot-HyperV_vmList.csv"
    $postRebootVMStatus = Import-Csv -Path "C:\Windows\System32\Reboot-HyperV_vmList.csv"

    $hasErrors = $false

    for ($i = 0; $i -lt $postRebootVMStatus.Length; $i++) {
        $currentVMInFile = $postRebootVMStatus[$i]

        if ($currentVMInFile.State -eq "Running") {

            try {
                Get-VM -Name "$($currentVMInFile.Name)" -ErrorAction Stop
            } catch {
                Write-Output "Failed to start VM: $($currentVMInFile.Name)."
                $hasErrors = $true
            }

            Write-Output "Starting VM $($currentVMInFile.Name)"
            Start-VM -Name "$($currentVMInFile.Name)"
        }
    }

    if ($hasErrors) {
        return 1
    }

    return 0
}

function main {
    switch($checkMode) {
        "prereboot" {
            preReboot
            shutdownVMs
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
            write-Output "Unknown option selected. Exiting Script."
        }
    }

    return 0
}