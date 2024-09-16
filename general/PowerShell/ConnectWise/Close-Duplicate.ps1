param (
    $CWEndpoint, 
    $CWCompanyID,
    $CWPublicKey,
    $CWPrivateKey,
    $CWClientID,
    [Int32]
    $parentTicketId,
    $summary,
    [Int32]
    $ticketTypeId,
    [Int32]
    $ticketSubTypeId,
    [Int32]
    $ticketItemId,
    [Int32]
    $ticketStatusId,
    [Int32]
    $ownerId,
    [hashtable[]]
    $list
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

function Connect-CWMTenant() {
    Import-Module 'ConnectWiseManageAPI' | Out-Null

    Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
    Connect-CWM @CWMConnectionInfo -Force
}

function Disconnect-CWMTenant() {
    Disconnect-CWM
}

function Update-Type($ticketID, $summary, $typeID) {
    $type = @{}
    if ($typeID -eq -1) {
        $type = @{
            ID = $ticketID
            Operation = "replace"
            Path = "type"
            Value = @{} #name=Sheen Ismhael Lim;}
        }
    } else {
        $type = @{
            ID = $ticketID
            Operation = "replace"
            Path = "type"
            Value = @{id=$typeID} 
        }
    }

    Write-Output "Updating Type to $($typeID) for $($ticketID) $($summary)"
    Update-CWMTicket @type | Out-Null
}

function Update-SubType($ticketID, $summary, $subTypeId) {
    $subType = @{}

    if ($subTypeId -eq -1) {
        $subType = @{
            ID = $ticketID
            Operation = "replace"
            Path = "subType"
            Value = @{} 
        }
    } else {
        $subType = @{
            ID = $ticketID
            Operation = "replace"
            Path = "subType"
            Value = @{id=$subTypeId}
        }
    }

    Write-Output "Updating SubType to $($subTypeId) for $($ticketID) $($summary)"
    Update-CWMTicket @subType | Out-Null
}

function Update-Status($ticketID, $summary, $statusid) {
    $closeStatus = @{
        ID = $ticketID
        Operation = "replace"
        Path = "status"
        Value = @{id=$statusid} 
    }

    Write-Output "Updating Status to $($statusid) on Ticket $($ticketID) $($summary)"
    Update-CWMTicket @closeStatus | Out-Null
}

function Update-Summary($ticketID, $summary) {
    $updatedSummary = @{
        ID = $ticketID
        Operation = "replace"
        Path = "summary"
        Value = $summary # status for completed is 31
    }

    Write-Output "Updating Summary for Ticket $($ticketID) - New Summary: $($summary)"
    Update-CWMTicket @updatedSummary | Out-Null
}

function Update-Item($ticketID, $summary, $itemId) {
    if ($itemId -eq -1 ){
        $updatedItem = @{
            ID = $ticketID
            Operation = "replace"
            Path = "item"
            Value = @{} # status for completed is 31
        }
    } else {
        $updatedItem = @{
            ID = $ticketID
            Operation = "replace"
            Path = "item"
            Value = @{id=$itemId} # status for completed is 31
        }
    }

    Write-Output "Updating item to $($itemId) for Ticket $($ticketID)"
    Update-CWMTicket @updatedItem | Out-Null
}

function Update-Owner($ticketID) {
    $ticketOwner = @{
        ID = $ticketID
        Operation = 'replace'
        Path = 'owner'
        Value = @{id=$ownerId}
    }

    Write-Output "Updating Resources and Ticket Owner to $($ownerId) for $($ticketID) $($thisTicket.summary)"
    Update-CWMTicket @ticketOwner | Out-Null
}

function Close-DuplicateTickets {
    param(
        $parentTicketId,
        $ticketTypeId,
        $ticketSubTypeId,
        $ticketItemId,
        $ticketStatusId,
        $summary,
        $ownerId
    )

    $duplicateTickets = @(Get-CWMTicket -condition ('((status/name = "New" or status/name = "New from RMM" or status/name = "New \(email connector\)") and (board/name = "Zenith" or board/name = "Monitoring" or board/name = "Patching" or board/name = "System Performance") and (summary like "' + $summary + '"))'))
    #$unassignedZenithfTicket = @(Get-CWMTicket -condition ('((status/name = "New" or status/name = "New from RMM" or status/name = "New \(email connector\)") and (board/name = "Zenith" or board/name = "Monitoring" or board/name = "Patching" or board/name = "System Performance") and resources = null and (summary like "' + $summary + '"))'))

    for ($i=0; $i -lt $duplicateTickets.Length; $i++) {
        $currentTicket = $duplicateTickets[$i];

        if ($currentTicket.id -eq $parentTicketId) {
            Write-Host "TicketID: $($currentTicket.id), This is the parent ticket, skipping."
            continue;
        }

        Update-Status -ticketID $currentTicket.id -summary $currentTicket.summary -statusid $ticketStatusId

        if ($currentTicket.summary.Length -ge 80) {
            Update-Summary -ticketID $currentTicket.id -summary "$($currentTicket.summary.SubString(0, 80)) | Duplicate $($parentTicketId)"
        } else {
            Update-Summary -ticketID $currentTicket.id -summary "$($currentTicket.summary) | Duplicate $($parentTicketId)"
        }
        
        Update-Item -ticketID $currentTicket.id -summary $currentTicket.summary -itemId $ticketItemId
        Update-SubType -ticketID $currentTicket.id -summary $currentTicket.summary -subTypeId $ticketSubTypeId
        Update-Type -ticketID $currentTicket.id -summary $currentTicket.summary -typeID $ticketTypeId

        Update-Owner -ticketID $currentTicket.id
    }
}

function main() {
    Connect-CWMTenant

    if ($null -ne $list) {
        for ($i=0; $i -lt $list.Length; $i++) {
            $currentEntry = $list[$i];
            $parentTicketId = $currentEntry.ticketId
            $summary = $currentEntry.ticketSummary

            Close-DuplicateTickets -parentTicketId $parentTicketId `
                -ticketTypeId $ticketTypeId `
                -ticketSubTypeId $ticketSubTypeId `
                -ticketItemId $ticketItemId `
                -ticketStatusId $ticketStatusId `
                -summary $summary `
                -ownerId $ownerId
        }
    } else {
        Close-DuplicateTickets -parentTicketId $parentTicketId `
            -ticketTypeId $ticketTypeId `
            -ticketSubTypeId $ticketSubTypeId `
            -ticketItemId $ticketItemId `
            -ticketStatusId $ticketStatusId `
            -summary $summary `
            -ownerId $ownerId
    }
    
    


    Disconnect-CWMTenant
}

main