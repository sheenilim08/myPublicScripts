# Author: Sheen Ismhael Lim
# Company: Modo Networks

#
param(
    [Parameter(HelpMessage="The Organization that the agent will belong to.")]
    $org, 

    [Parameter(HelpMessage="The Site that the agent will belong to.")]
    $site, 

    [Parameter(HelpMessage="The username credential to use to register the endpoint to shadowcontrol.")]
    $username, 
    
    [Parameter(HelpMessage="The username credential to use to register the endpoint to shadowcontrol.")]
    $password, 

    [Parameter(HelpMessage="The endpoint server to connect the shadowcontrol agent.")]
    $serverEndpoint, 
    
    [Parameter(HelpMessage="The type of endpoint the computer is going to be. Values can be - desktop,server,laptop,virtual")]
    $type="server")

function Rename-File($fileToRename,$dateTime) {
    $newFileName = "$($fileToRename)_$($dateTime)";

    if (Test-Path -Path $fileToRename) {
        Write-Output "Renaming the file $($fileToRename) to $($newFileName)";
        try {
            Rename-Item -Path "$fileToRename" -NewName $newFileName;
        } catch {
            Write-Output "An error occured while trying to rename the file.";
            Write-Output "Old File: $($fileToRename).";
            Write-Output "New File: $($newFileName).";
        }
    } else {
        Write-Output "The file $($fileToRename) does not exist, skipping.";
    }
}

function main() {
    $shadowControlService = Get-Service "stc_endpt_svc";

    $dateTime = $(Get-Date -Format 'MM-dd-yyyy_HH-mm');

    if ($shadowControlService -ne $null) {
        if (Test-Path -Path "C:\ProgramData\StorageCraft\.machine.id") {
            $currentMachineID = Get-Content -Path "C:\ProgramData\StorageCraft\.machine.id";
            Write-Output "Current Machine ID: $($currentMachineID)";

            Rename-File -fileToRename "C:\ProgramData\StorageCraft\.machine.id" -dateTime $dateTime;
        } else {
            Write-Output "The machine ID file could not be found.";
        }

        if ($shadowControlService.Status -eq "Running") {
            Write-Output "Stopping the 'StorageCraft EndPoint Agent' Service.";
            $shadowControlService | Stop-Service;
        } else {
            Write-Output "Service 'StorageCraft EndPoint Agent' is not running.";
        }

        Rename-File -fileToRename "C:\ProgramData\StorageCraft\endpt\endpt.db3" -dateTime $dateTime;
        Rename-File -fileToRename "C:\ProgramData\StorageCraft\endpt\endpt_config.json" -dateTime $dateTime;

        Write-Output "Starting the 'StorageCraft EndPoint Agent' Service";
        $shadowControlService | Start-Service;

        Write-Output "Register to endpoint";
        
        Set-Location "C:\Program Files (x86)\StorageCraft\CMD";
        .\stccmd.exe subscribe -o "$($org):$($site)" -U $($username) -P $($password) -m $($type) "$($serverEndpoint)";

        $newMachineID = Get-Content -Path "C:\ProgramData\StorageCraft\.machine.id";
        Write-Output "New Machine ID: $($newMachineID)";

        return 0;
    } else {
        Write-Output "An issue occured while trying to get the Service information for stc_endpt_svc (StorageCraft EndPoint Agent)";
        return 1;
    }
}

main