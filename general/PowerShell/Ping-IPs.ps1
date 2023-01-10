$csvFile = Import-Csv -Path "Path_to_File.csv"

$resultObject = @()

$csvFile | ForEach-Object {
    Write-Output "Testing $($_."IP ADDRESS")"
    $result = Test-Connection -ComputerName $_."IP ADDRESS"
    
    
    $isUp = $false;
    if ($result) {
        $isUp = $true;
    }

    $thisResult = New-Object -TypeName PSObject
    $thisResult | Add-Member -MemberType NoteProperty -Name IPAddress -Value $_."IP ADDRESS"
    $thisResult | Add-Member -MemberType NoteProperty -Name ReplyInconsistency -Value $result.ReplyInconsistency
    $thisResult | Add-Member -MemberType NoteProperty -Name isUP -Value $isUp

    $resultObject += $thisResult
}

$resultObject

Write-Output "Exporting Result to PingResult.csv"
$resultObject | Export-Csv -Path PingResult.csv