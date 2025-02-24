try {
    $monitoredProcessList = $env:monitoredprocesslist_param.Trim().Replace(" ", "");
    
} catch {
    Write-Host "Script Failed. Exiting."
    Write-Host "An issue occured while parsing the process list to monitor."
    exit 2
}

$comparisonCondition = $env:comparisoncondition_param
$userSpace = $env:userspace_param

function main() {
    $processes = @($monitoredProcessList.split(","));

    $isThereError = $false;

    for ($i = 0; $i -lt $processes.Length; $i++) {
        $thisProcess = Get-Process -Name $processes[$i] -IncludeUserName -ErrorAction SilentlyContinue

        if ($thisProcess) {
            if ($userSpace -ne "") {
                switch ($comparisonCondition) {
                    "Equals" { 
                        if ($thisProcess.Username.ToLower() -ne $userSpace.ToLower()) {
                            Write-Host "The monitored process $($processes[$i]) has not satisfied the preffered condition."
                            Write-Host "Condition: Process $($processes[$i]) SHOULD BE running under $($userSpace)."
                            $isThereError = $true;
                        }
                    }
                    "NotEquals" { 
                        if ($thisProcess.Username.ToLower() -eq $userSpace.ToLower()) {
                            Write-Host "The monitored process $($processes[$i]) has not satisfied the preffered condition."
                            Write-Host "Condition: Process $($processes[$i]) SHOULD NOT BE running under $($userSpace)."
                            $isThereError = $true;
                        }
                    }
                    default {
                        Write-Host "Unknown Comparison Operator."
                        exit 2
                    }
                }
            }
        } else {
            Write-Output "The monitoring process $($process[$i]) is not running."
            $isThereError = $true;
        }
    }

    if ($isThereError) {
        Write-Host "Multiple processes has not satisfied the preferred condition."
        Write-Host "Please Refer to Documentation. https://modo-networks-llc.itglue.com/1749534/docs/17156414"
        exit 1
    }
}

main