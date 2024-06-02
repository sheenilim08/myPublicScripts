# Code Wrapper used is from
# https://github.com/christaylorcodes/ConnectWiseManageAPI


param(
    $CWEndpoint, 
    $CWCompanyID,
    $CWPublicKey,
    $CWPrivateKey.
    $CWClientID
)

$CWMConnectionInfo = @{
  # This is the URL to your manage server.
  Server      = $CWEndpoint
  # This is the company entered at login
  Company     = $CWCompanyID
  # Public key created for this integration
  pubkey      = $CWPublicKey
  # Private key created for this integration
  privatekey  = $CWPrivateKey
  # Your ClientID found at https://developer.connectwise.com/ClientID
  clientid    = $CWClientID
}

Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
Connect-CWM @CWMConnectionInfo -Force

Write-Output "Querying Unassigned Tickets - Professional Services..."
$unassignedProfTicket = @(Get-CWMTicket -condition '((status/name = "New" or status/name = "New \(email connector\)") and board/name = "Professional Services" and resources = null)')

$unassignedProfTicket | Foreach-Object {
    $ticketID = $_.id

    $ticketOwner = @{
        ID = $ticketID
        Operation = 'replace'
        Path = 'owner'
        Value = @{id=268}
    }

    Write-Output "Updating Resources and Ticket Owner for $($ticketID) $($_.summary)"
    Update-CWMTicket @ticketOwner
#    New-CWMScheduleEntry -member @{identifier = "SLim"} -objectId $ticketID -type @{id=4}
}

Write-Output "Querying Unassigned Tickets - Zenith..."
$unassignedZenithfTicket = @(Get-CWMTicket -condition '((status/name = "New" or status/name = "New \(email connector\)") and board/name = "Zenith" and resources = null and (summary not contains "desktop"))')

$unassignedZenithfTicket | Foreach-Object {
    $ticketID = $_.id

    $ticketOwner = @{
        ID = $ticketID
        Operation = 'replace'
        Path = 'owner'
        Value = @{id=268}
    }

    Write-Output "Updating Resources and Ticket Owner for $($ticketID) $($_.summary)"
    Update-CWMTicket @ticketOwner
#    New-CWMScheduleEntry -member @{identifier = "SLim"} -objectId $ticketID -type @{id=4}
}

Disconnect-CWM