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

function Update-Company($ticketID, $summary, $companyid) {
    $companyInfo = @{
        ID = $ticketID
        Operation = "replace"
        Path = "company"
        Value = @{id=$companyid} #; name=Modo Networks, LLC};
    }
    Write-Output "Updating Company for $($ticketID) $($summary)"
    Update-CWMTicket @companyInfo | Out-Null
}

function Update-Contact($ticketID, $summary, $contactId=20354) {
    $sheenContact = @{
        ID = $ticketID
        Operation = "replace"
        Path = "contact"
        Value = @{id=$contactId} #name=Sheen Ismhael Lim;}
    }

    Write-Output "Updating Company for $($ticketID) $($summary)"
    Update-CWMTicket @sheenContact | Out-Null
}

function Update-Type($ticketID, $summary, $typeID) {
    $type = @{
        ID = $ticketID
        Operation = "replace"
        Path = "type"
        Value = @{id=$typeID} #name=Sheen Ismhael Lim;}
    }

    Write-Output "Updating Type for $($ticketID) $($summary)"
    Update-CWMTicket @type | Out-Null
}

function Update-SubType($ticketID, $summary, $subTypeId) {
    $subType = @{
        ID = $ticketID
        Operation = "replace"
        Path = "subType"
        Value = @{id=$subTypeId} #name=Sheen Ismhael Lim;}
    }

    Write-Output "Updating SubType for $($ticketID) $($summary)"
    Update-CWMTicket @subType | Out-Null
}

function Update-Status($ticketID, $summary, $statusid) {
    $closeStatus = @{
        ID = $ticketID
        Operation = "replace"
        Path = "status"
        Value = @{id=$statusid} 
    }

    Write-Output "Updating Status on Ticket $($ticketID) $($summary)"
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
    $updatedItem = @{
        ID = $ticketID
        Operation = "replace"
        Path = "item"
        Value = @{id=$itemId} # status for completed is 31
    }

    Write-Output "Updating item for Ticket $($ticketID)"
    Update-CWMTicket @updatedItem | Out-Null
}

function main() {
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

        if ($_.summary.ToString().ToLower().Contains("shadowcontrol itsm")) {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 341 # 341 is the "Modo Networks"
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 50 # 50 is the subtype for SubType: Backup

        } elseif ($_.summary.ToString().ToLower().Contains("bug fix advisory") -or $_.summary.ToString().ToLower().Contains("enhancement advisory")) {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 341 # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $_.summary
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 29 # 29 is the type for Type: Vendor
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 9706 # 9706 is the subtype for SubType: Redhat

        } elseif ($_.summary.ToString().ToLower() -contains "*consistency check of system volume * on * is complete" -or $_.summary.ToString().ToLower() -contains "*Monthly Drive Health Report on * - Healthy") {
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 83 # 83 is the subtype for SubType: SAN
            Update-Item -ticketID $ticketID -summary $_.summary -itemId 96 # 96 is the Item:Maintenance

        } elseif ($_.summary.ToString().ToLower().Contains("[OUT OF PROTECTION THRESHOLD]")) {
            # Must be assign to each company - do not automate this part for this ticket.
            # Update-Company -ticketID $ticketID -summary $_.summary -companyid 341  # 341 is the "Modo Networks"
            # Update-Contact -ticketID $ticketID -summary $_.summary
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 50 # 50 is the subtype for SubType: Backup
            Update-Item -ticketID $ticketID -summary $_.summary -itemId 3 # 3467 is the Item: Failure

        } elseif ($_.summary.ToString().ToLower().Contains("new login to your synology nas") -or $_.summary.ToString().ToLower().Contains("el rio iscsi]drive 5 in rs2414+ is failing") -or $_.summary.ToString().ToLower() -like "* is in extremely low capacity") {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 341  # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $_.summary
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 13 # 13 is the type for Type: Server
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 83 # 83 is the subtype for SubType: SAN

        } elseif ($_.summary.ToString().Contains("[rr-nas-02] Backup statistics alerts on RR-NAS-02")) {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 11020 # ID for Regal
            Update-Contact -ticketID $ticketID -summary $_.summary -contactId 20528 # ID for Modo Alerts
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 43 # 43 is the type for application
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 50 # 50 is the subtype for SubType: Backup
            Update-Item -ticketID $ticketID -summary $_.summary -itemId 3467 # 3467 is the Item: Cloud

        } elseif ($_.summary.ToString().Contains("INTELLA - REORGANIZE")) {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 12231 # ID for TransStar National Title
            Update-Contact -ticketID $ticketID -summary $_.summary
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 13 # 13 is the type for Type: Server
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 906 # 129 is the subtype for SubType: Service

        }elseif ($_.summary.ToString().ToLower().Contains("your ssl certificate is coming up for renewal.")) {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 341  # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $_.summary
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 30 # 30 is the subtype for SubType: Website
            Update-Item  -ticketID $ticketID -summary $_.summary -itemId 18 # 18 is the item for Item: Certificate

        } elseif ($_.summary.ToString() -eq "Microsoft 365 security: You have messages in quarantine") {
            Update-Company -ticketID $ticketID -summary $_.summary -companyid 341  # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $_.summary
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 58 # 58 is the subtype for SubType: Email
            Update-Item  -ticketID $ticketID -summary $_.summary -itemId 502 # 502 is the item for Item: Spam
        }

        if ($_.summary.ToString().ToLower().Contains("el rio iscsi]drive 5 in rs2414+ is failing")) {
            Update-Summary -ticketID $ticketID -summary "$($_.summary) | Duplicate 376993"
        }

        if ($_.summary.ToString().Contains("[rr-nas-02] Backup statistics alerts on RR-NAS-02") -or $_.summary.ToString().ToLower() -like "*consistency check of system volume * on * is complete" -or $_.summary.ToString().ToLower().Contains("el rio iscsi]drive 5 in rs2414+ is failing") -or $_.summary.ToString().ToLower().Contains("bug fix advisory") -or $_.summary.ToString().ToLower().Contains("enhancement advisory") -or $_.summary.ToString().ToLower() -contains "*Monthly Drive Health Report on * - Healthy" -or $_.summary.ToString().Contains("INTELLA - REORGANIZE")) {
            Update-Status -ticketID $ticketID -summary $_.summary -statusid 31 # status for completed is 31
        } else {
            Update-Status -ticketID $ticketID -summary $_.summary -statusid 36 # status for Assigned is 36
        }
    }

    Write-Output "Querying Unassigned Tickets - Zenith..."
    $unassignedZenithfTicket = @(Get-CWMTicket -condition '((status/name = "New" or status/name = "New \(email connector\)") and (board/name = "Zenith" or board/name = "Patching" or board/name = "System Performance") and resources = null and (summary not contains "desktop"))')

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

        if ($_.summary.ToString().ToLower().Contains("Server reboot pending after patch installation")) {
            Update-Type -ticketID $ticketID -summary $_.summary -typeID 33 # 33 is the type for Type: Server
            Update-SubType -ticketID $ticketID -summary $_.summary -subTypeId 125 # 125 is the subtype for SubType: Update

        }
    }

    Disconnect-CWM
}

main