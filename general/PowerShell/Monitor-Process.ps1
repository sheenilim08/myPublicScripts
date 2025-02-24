try {
    $monitoredProcessList = $env:monitoredProcessList_Param.ToString().Trim().Replace(" ", "");
} catch {
    Write-Host "Script Failed. Exiting."
    Write-Host "An issue occured while parsing the process list to monitor."
    exit 2
}

$comparisonCondition = $env:comparisonCondition_Param
$userSpace = $env:userSpace_Param

function main() {
    $processes = $monitoredProcessList.split(",");

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
                }
            }
        } else {
            Write-Output "The monitoring process $(process[$i]) is not running."
            $isThereError = $true
        }
    }

    if ($isThereError) {
        Write-Host "`nMultiple processes has not satisfied the preferred condition."
        exit 1
    }
}

main