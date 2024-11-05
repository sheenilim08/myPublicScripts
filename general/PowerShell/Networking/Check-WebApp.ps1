$endpointToMonitor = $env:endpointToMonitor_param
$organisationName = $env:organisationName_param
$kbLink = $env:kbLink_param

function main {
    try {
        $HTTP_Request = [System.Net.WebRequest]::Create($endpointToMonitor)
        $HTTP_Response = $HTTP_Request.GetResponse()
    } catch {
        Write-Output "An error occured while performing web app check."
        return 2
    }

    $HTTP_Status = [int]$HTTP_Response.StatusCode

    if ($HTTP_Status -eq 200) {
        Write-Output "Site is OK!"
    } else {
        Write-Output "$($organisationName) - Eclipse Server: $($endpointToMonitor)"
        Write-Output "The Site may be down, please check!"
        Write-Output "Documentation: $($kbLink)"

        return 1;
    }

    if ($HTTP_Response -ne $null) { 
        $HTTP_Response.Close() 
    }

    return 0;
}

main