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

if (Get-InstalledModule 'ConnectWiseManageAPI' -ErrorAction SilentlyContinue){ 
    Update-Module 'ConnectWiseManageAPI' -Verbose -Force 
}

else { 
    Install-Module 'ConnectWiseManageAPI' -Verbose -Force
}

Import-Module 'ConnectWiseManageAPI'

Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
Connect-CWM @CWMConnectionInfo -Force

Write-Output "Querying Unassigned Tickets - Professional Services..."
$unassignedProfTicket = @(Get-CWMTicket -condition '((status/name = "New" or status/name = "New \(email connector\)") and board/name = "Professional Services" and resources = null)')

$unassignedProfTicket | Foreach-Object {
    $ticketID = $_.id
    # This must be done first for voice mail tickets otherwise, all other update commands will fail because the email is invalid for this ticket.
    # This is a special case for voice mail tickets.
    if ($_.summary.ToString().Tolower().Contains("shared voicemail (support voicemail number)")) {
        $sheenContactEmail = @{
            ID = $ticketID
            Operation = "replace"
            Path = "contactEmailAddress"
            Value = "slim@modonetworks.net"
        }

        Write-Output "Updating Email address for $($ticketID) $($summary)"
        Update-CWMTicket @sheenContactEmail | Out-Null
    }


    $ticketOwner = @{
        ID = $ticketID
        Operation = 'replace'
        Path = 'owner'
        Value = @{id=268}
    }

    Write-Output "Updating Resources and Ticket Owner for $($ticketID) $($_.summary)"
    Update-CWMTicket @ticketOwner | Out-Null
#    New-CWMScheduleEntry -member @{identifier = "SLim"} -objectId $ticketID -type @{id=4}
    
    
    if ($_.summary.ToString().ToLower().Contains("bug fix advisory")) {
        $companyInfo = @{
            ID = $ticketID
            Operation = "replace"
            Path = "company"
            Value = @{id=157} #; name=Modo Networks, LLC};
        }

        $sheenContact = @{
            ID = $ticketID
            Operation = "replace"
            Path = "contact"
            Value = @{id=20354} #name=Sheen Ismhael Lim;}
        }

        Write-Output "Updating Company for $($ticketID) $($_.summary)"
        Update-CWMTicket @companyInfo | Out-Null
        Update-CWMTicket @sheenContact | Out-Null

        $closeStatus = @{
            ID = $ticketID
            Operation = "replace"
            Path = "status"
            Value = @{id=31} # status for completed is 31
        }

        Write-Output "Closing Ticket $($ticketID)"
        Update-CWMTicket @closeStatus | Out-Null
    }
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
    Update-CWMTicket @ticketOwner | Out-Null
#    New-CWMScheduleEntry -member @{identifier = "SLim"} -objectId $ticketID -type @{id=4}
}

Disconnect-CWM