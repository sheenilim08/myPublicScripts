# CSV file must have a column with "IP ADDRESS" that contains ip addresses to check
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
$noticeMessage = "
Output will look like below, the ReplyInconsistency will have 4 result since Test-Connection will try to ping the IP 4 times
Normally it will return false and true when there is large latency difference between pings
IPAddress    ReplyInconsistency           isUP
---------    ------------------           ----
172.24.1.117 {False, False, False, False} True
172.24.1.158 {False, False, False, False} True"

Write-Output $noticeMessage
$resultObject | Export-Csv -Path PingResult.csv