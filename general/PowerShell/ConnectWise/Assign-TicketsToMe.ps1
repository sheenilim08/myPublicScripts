# Code Wrapper used is from
# https://github.com/christaylorcodes/ConnectWiseManageAPI


param(
    $CWEndpoint, 
    $CWCompanyID,
    $CWPublicKey,
    $CWPrivateKey,
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

function updateCompanyBySynAppliance($thisTicket) {
    $_ = $thisTicket.summary
    $ticketID = $thisTicket.id

    switch ($_.tostring().tolower()) {
        {$_ -like "*alltech*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11820  # 11820 is the "AllTech"
        }
        {$_ -like "*alpha-nfs-syn*" -or $_ -like "*alpha-remote*" -or $_ -like "*alpha-bu-syn*" -or $_ -like "*alpha-nfs2*" -or 
         $_ -like "*alpha-hyperv1*" -or $_ -like "*dc-server*" -or $_ -like "*file-server*" -or $_ -like "*fm-server*" -or $_ -like "*fm-server2*" -or 
         $_ -like "*web-server*" -or $_ -like "*web-server2*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12191  # 12191 is the "Alpha Energy Labs - Bio Aquatic"
        }
        {$_ -like "*gingermarie*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12309  # 12309 is the "Ginger Marie"
        }
        {$_ -like "*gme-bu-syn*" -or $_ -like "*gme-rmte-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 10505  # 10505 is the "George McKenna Electrical Contractors Inc"
        }
        {$_ -like "*bwc-bu-syn*" } {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12195  # 12195 is the "Blackwater Communications"
        }
        {$_ -like "*oldham-bu-syn*" } {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12228  # 12228 is the "Oldham Lumber Co., Inc"
        }
        {$_ -like "*craters-bu-syn*" } {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12176  # 12176 is the "Craters and Freighters"
        }
        {$_ -like "*ricks-syn-bu*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11741  # 11741 is the "Ricks Hardware"
        }
        {$_ -like "*circlez-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11736  # 11736 is the "Pump Down Specialist"
        }
        {$_ -like "*eraid-001*" -or $_ -like "*braz-syn-rs2821*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12274  # 12274 is the "Brazen Animation"
        }
        {$_ -like "*apaa-syn-new*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11844  # 11844 is the "APAA Recovery"
        }
        {$_ -like "*nel-bk-str*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 215  # 215 is the "Neligan LLP"
        }
        {$_ -like "*epic-haltom*" -or $_ -like "*epic-dallas*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 193  # 193 is the "Epic Supply"
        }
        {$_ -like "*sei-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 5594  # 5594 is the "Southern Enterprises Inc (SEI)"
        }
        {$_ -like "*colonial-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12270  # 12270 is the "Colonial Truss"
        }
        {$_ -like "*erg-new-bu-syn*" -or $_ -like "*el rio iscsi*" -or $_ -like "*elrioiscsi*" -or $_ -like "*erg-new-corp-bu*" -or $_ -like "erg-shstor"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 198  # 198 is the "El Rio Grande"
        }
        {$_ -like "*sa-bu-remote*" -or $_ -like "*sa-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12260  # 12260 is the "Style Access"
        }
        {$_ -like "*spm-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11802  # 11802 is the "SPM Communications"
        }
        {$_ -like "*ntxobgyn-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12165  # 12165 is the "North Texas Ob-Gyn Associates"
        }
        {$_ -like "*mei-backup*" -or $_ -like "*mei-backup2*" -or $_ -like "*fbserver2*" -or $_ -like "*mei-dc01*" -or $_ -like "*mei-ibml*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12136  # 12136 is the "MEI Mail & Document Management Services"
        }
        {$_ -like "*immunenas1*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12219  # 12219 is the "ImmuneSensor Therapeutics"
        }
        {$_ -like "*zeus*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12136  # 6928 is the "WinSystems"
        }
        {$_ -like "*transtar-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12231  # 12231 is the "TranStar National Title"
        }
        {$_ -like "*djs-bu-syn*" -or $_ -like "*djs-nfs-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 10679  # 10679 is the "DJS International Services Inc"
        }
        {$_ -like "*transtar-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12231  # 12231 is the "TranStar National Title"
        }
        {$_ -like "*tptdsbu*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 218   # 218  is the "Texas Pioneer Title"
        }
        {$_ -like "*nws-br27*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11784  # 11784 is the "National Wholesale Supply - Longview BR27"
        }
        {$_ -like "*nws-colo2*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 165  # 165 is the "National Wholesale Supply - Data Center"
        }
        {$_ -like "*nws-dal-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 164  # 164 is the "National Wholesale Supply - Dallas BR5"
        }
        {$_ -like "*branch 41*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12269  # 12269 is the "National Wholesale Supply - Dallas 41"
        }
        {$_ -like "*leonard-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 6476  # 6476 is the "Leonard Sloan and Associates, Inc."
        }
        {$_ -like "*resource-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12306  # 12306 is the "Re-Source Industries"
        }
        {$_ -like "*access-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12178  # 12178 is the "Access XP LLC"
        }
        {$_ -like "*yeager-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 243  # 243 is the "Yeager & Company"
        }
        {$_ -like "*swa-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11839  # 11839 is the "Southwest Air Equipment"
        }
        {$_ -like "*modo-ds218*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 157  # 157 is the "Modo Networks, LLC"
        }
        {$_ -like "*rg-bu-syn*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12121  # 12121 is the "Richard A. Gump Jr. P.C."
        }
        {$_ -like "*ach-primary-bu*" -or $_ -like "*ach-remote-bu*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11809  # 11809 is the "ACH Child and Family Services"
        }
        {$_ -like "*rr-nas-01*" -or $_ -like "*rr-nas-02*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11020  # 11020 is the "Regal"
        }
        {$_ -like "*pittman-backup*" -or $_ -like "*pittman-storage*" -or $_ -like "*pittman-ofc-ds*"} {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11728  # 11728 is the "Pittman Plumbing Supply"
        }
    }
}

function addCustomNotes($thisTicket) {
    $_ = $thisTicket.summary
    $ticketID = $thisTicket.id

    switch ($_.tostring().tolower()) {
        {$_ -eq "access-bu-syn packages on access-bu-syn are out-of-date"} {
            New-CWMTicketNote -parentId $ticketID -text 'No longer a client' -detailDescriptionFlag $true -internalAnalysisFlag $false -resolutionFlag $false
        }
        {$_ -eq "[el rio iscsi]issues occurred to drive 5 in rs2414+"} {
            $note = "- See 374303. Evan has informed me that El Rio will most likely replace the entire appliance soon. No need to renew any disk on this appliance. Appliance has 2 spare HDD as well."
            New-CWMTicketNote -parentId $ticketID -text $note -detailDescriptionFlag $true -internalAnalysisFlag $false -resolutionFlag $false
        }
        default { }
    }
}

function main() {
    Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
    Connect-CWM @CWMConnectionInfo -Force

    Write-Output "Querying Unassigned Tickets - Professional Services..."
    $unassignedProfTicket = @(Get-CWMTicket -condition '((status/name = "New" or status/name = "New \(email connector\)") and board/name = "Professional Services" and resources = null)')

    for ($i = 0; $i -lt $unassignedProfTicket.Length; $i++) {
    #$unassignedProfTicket | Foreach-Object {
        $thisTicket =  $unassignedProfTicket[$i];
        $ticketID = $thisTicket.id
        # This must be done first for voice mail tickets otherwise, all other update commands will fail because the email is invalid for this ticket.
        # This is a special case for voice mail tickets.

        if ($thisTicket.summary.ToString().Tolower().Contains("shared voicemail (support voicemail number)")) {
            $sheenContactEmail = @{
                ID = $ticketID
                Operation = "replace"
                Path = "contactEmailAddress"
                Value = "slim@modonetworks.net"
            }

            Write-Output "Updating Email address for $($ticketID) $($thisTicket.summary)"
            Update-CWMTicket @sheenContactEmail | Out-Null
        }

        $ticketOwner = @{
            ID = $ticketID
            Operation = 'replace'
            Path = 'owner'
            Value = @{id=268}
        }

        if ($thisTicket.contactEmailAddress.tolower().contains("ericson@modo") -or $thisTicket.contactName.tolower().contains("eric") -or $thisTicket.summary.ToString().ToLower().Contains("test") -or $thisTicket.summary.ToString().ToLower().Contains("ericson") -or $thisTicket.summary.ToString().ToLower() -like "*test*" -or $thisTicket.summary.ToString().ToLower().Contains("assign") -or 
            $thisTicket.contactEmailAddress.tolower().contains("laura@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("roger@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("mark@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("mitch@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("laura@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("yesenia@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("sergio@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("kid@modo") -or
            $thisTicket.contactEmailAddress.tolower().contains("michael.oliver@modo") -or 
            $thisTicket.contactEmailAddress.tolower().contains("seamus@modo") -or
            $thisTicket.summary.ToString().ToLower().Contains("nonfte scheduled departure") -or
            $thisTicket.summary.ToString().ToLower().Contains("laptop coc")) {
            Write-Output "Skipping $($ticketID) - $($thisTicket.summary)"
            continue;
        } 

        Write-Output "Updating Resources and Ticket Owner for $($ticketID) $($thisTicket.summary)"
        Update-CWMTicket @ticketOwner | Out-Null
    #    New-CWMScheduleEntry -member @{identifier = "SLim"} -objectId $ticketID -type @{id=4}
        
        if ($thisTicket.summary.ToString().ToLower().Contains("shadowcontrol itsm: critical") -or
            $thisTicket.summary.ToString().ToLower() -like "*the health status of device*") {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341 # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 50 # 50 is the subtype for SubType: Backup
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 3 # 3 is the Item:Failure
            
            updateCompanyBySynAppliance -thisTicket $thisTicket

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("shadowcontrol itsm: warning")) {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341 # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 50 # 50 is the subtype for SubType: Backup

            updateCompanyBySynAppliance -thisTicket $thisTicket
            

        } elseif ($thisTicket.summary.ToString().ToLower() -like "*alert for *") {
            updateCompanyBySynAppliance -thisTicket $thisTicket
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 14 # 14 is the subtype for SubType: Firewall

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("ups: battery") -and $thisTicket.contactEmailAddress -eq "NWS-BR5-APC@nationalwholesale.biz") {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 164 # 164 is the "National Wholesale Supply - Dallas BR5"
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 51 # 51 is the type for Type: Duplicate
            
            Update-Summary -ticketID $ticketID -summary "$($thisTicket.summary) | Duplicate 470963"

        }  elseif ($thisTicket.summary.ToString().ToLower() -like "alert for * - uplink status changed" -or $thisTicket.summary.ToString().ToLower() -like "*appliance - vpn connectivity changed") {
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 14 # 14 is the subtype for SubType: Firewall
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 2 # 2 is the Item:Change
            

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("cisco dns daily report")) {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341 # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 37 # 37 is the subtype for SubType: DNS
            

        } elseif ($thisTicket.summary.ToString().ToLower() -like "*connection to * has been*") {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 83 # 83 is the subtype for SubType: SAN
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 249 # 249 is the Item:Power

            updateCompanyBySynAppliance -thisTicket $thisTicket
        } elseif ($thisTicket.summary.ToString().ToLower() -like "*packages on * are out-of-date") {
            
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 83 # 83 is the subtype for SubType: SAN
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 264 # 264 is the Item:Update

            updateCompanyBySynAppliance -thisTicket $thisTicket
            addCustomNotes -thisTicket $thisTicket

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("bug fix advisory") -or $thisTicket.summary.ToString().ToLower().Contains("enhancement advisory")) {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341 # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 29 # 29 is the type for Type: Vendor
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 9706 # 9706 is the subtype for SubType: Redhat

        } elseif ($thisTicket.summary.ToString().ToLower() -like "*is running out of available capacity") {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 83 # 83 is the subtype for SubType: SAN

            updateCompanyBySynAppliance -thisTicket $thisTicket

        } elseif ($thisTicket.summary.ToString().ToLower() -like "*consistency check of system volume * on * is complete" -or 
            $thisTicket.summary.ToString().ToLower() -like "*consistency check of storage pool * on * has ended" -or 
            $thisTicket.summary.ToString().ToLower() -like "*monthly drive health report on * - healthy" -or 
            $thisTicket.summary.ToString().ToLower() -like "*monthly disk health report*" -or
            $thisTicket.summary.ToString().ToLower() -like "*new login to your synology nas*" -or 
            $thisTicket.summary.ToString().ToLower() -like "*dsm has detected a new login behavior*" -or
            $thisTicket.summary.ToString().ToLower() -like "*issues occurred to drive*") {

            updateCompanyBySynAppliance -thisTicket $thisTicket

            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 83 # 83 is the subtype for SubType: SAN
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 96 # 96 is the Item:Maintenance

        } elseif ($thisTicket.summary.ToString().Contains("[OUT OF PROTECTION THRESHOLD]") -or $thisTicket.summary.ToString().ToLower() -like "*active backup for business - backup task*") {
            # Must be assign to each company - do not automate this part for this ticket.
            # Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341  # 341 is the "Modo Networks"
            # Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 50 # 50 is the subtype for SubType: Backup
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 3 # 3467 is the Item: Failure

            updateCompanyBySynAppliance -thisTicket $thisTicket

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("new login to your synology nas") -or $thisTicket.summary.ToString().ToLower().Contains("el rio iscsi]drive 5 in rs2414+ is failing") -or $thisTicket.summary.ToString().ToLower() -like "* is in extremely low capacity") {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341  # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 13 # 13 is the type for Type: Server
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 83 # 83 is the subtype for SubType: SAN

        } elseif ($thisTicket.summary.ToString().Contains("[rr-nas-02] Backup statistics alerts on RR-NAS-02")) {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 11020 # ID for Regal
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary -contactId 20528 # ID for Modo Alerts
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 43 # 43 is the type for application
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 50 # 50 is the subtype for SubType: Backup
            Update-Item -ticketID $ticketID -summary $thisTicket.summary -itemId 3467 # 3467 is the Item: Cloud

        } elseif ($thisTicket.summary.ToString().Contains("INTELLA - REORGANIZE")) {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 12231 # ID for TransStar National Title
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 13 # 13 is the type for Type: Server
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 906 # 129 is the subtype for SubType: Service

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("your ssl certificate is coming up for renewal.")) {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341  # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 30 # 30 is the subtype for SubType: Website
            Update-Item  -ticketID $ticketID -summary $thisTicket.summary -itemId 18 # 18 is the item for Item: Certificate

        } elseif ($thisTicket.summary.ToString() -eq "Microsoft 365 security: you have messages in quarantine") {
            Update-Company -ticketID $ticketID -summary $thisTicket.summary -companyid 341  # 341 is the "Modo Networks"
            Update-Contact -ticketID $ticketID -summary $thisTicket.summary
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 43 # 43 is the type for Type: Application
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 58 # 58 is the subtype for SubType: Email
            Update-Item  -ticketID $ticketID -summary $thisTicket.summary -itemId 502 # 502 is the item for Item: Spam

        } elseif ($thisTicket.summary.ToString() -like "[action required] verify that you own*") {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 44 # 44 is the type for Type: Network
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 830 # 830 is the subtype for SubType: Domain Name
            Update-Item  -ticketID $ticketID -summary $thisTicket.summary -itemId 200 # 200 is the item for Item: Renew
        }

        if ($thisTicket.summary.ToString().ToLower().Contains("el rio iscsi]drive 5 in rs2414+ is failing")) {
            Update-Summary -ticketID $ticketID -summary "$($thisTicket.summary) | Duplicate 376993"
        }

        if ($thisTicket.summary.ToString().Contains("[rr-nas-02] Backup statistics alerts on RR-NAS-02") -or 
        $thisTicket.summary.ToString().ToLower() -like "*consistency check of system volume * on * is complete" -or 
        $thisTicket.summary.ToString().ToLower().Contains("el rio iscsi]drive 5 in rs2414+ is failing") -or 
        $thisTicket.summary.ToString().ToLower().Contains("bug fix advisory") -or 
        $thisTicket.summary.ToString().ToLower().Contains("enhancement advisory") -or 
        $thisTicket.summary.ToString().ToLower() -like "*monthly drive health report on * - healthy" -or 
        $thisTicket.summary.ToString().Contains("INTELLA - REORGANIZE") -or
        $thisTicket.summary.ToString().ToLower() -like "*monthly disk health report*" -or 
        $thisTicket.summary.ToString() -eq "ACCESS-BU-SYN Packages on ACCESS-BU-SYN are out-of-date" -or
        $thisTicket.summary.ToString() -eq "[El Rio iSCSI]Issues occurred to Drive 5 in RS2414+" -or 
        $thisTicket.summary.ToString() -eq "UPS: Battery life exceeded. Order replacement battery, APCRBC140, for the in...") {
            Update-Status -ticketID $ticketID -summary $thisTicket.summary -statusid 31 # status for completed is 31
        } else {
            Update-Status -ticketID $ticketID -summary $thisTicket.summary -statusid 36 # status for Assigned is 36
        }
    }

    Write-Output "Querying Unassigned Tickets - Zenith..."
    $unassignedZenithfTicket = @(Get-CWMTicket -condition '((status/name = "New" or status/name = "New from RMM" or status/name = "New \(email connector\)") and (board/name = "Zenith" or board/name = "Monitoring" or board/name = "Patching" or board/name = "System Performance") and resources = null and (summary not contains "desktop"))')

    #$unassignedZenithfTicket | Foreach-Object {
    for ($i = 0; $i -lt $unassignedZenithfTicket.Length; $i++) {
        $thisTicket =  $unassignedZenithfTicket[$i];
        $ticketID = $thisTicket.id

        $ticketOwner = @{
            ID = $ticketID
            Operation = 'replace'
            Path = 'owner'
            Value = @{id=268}
        }

        Write-Output "Updating Resources and Ticket Owner for $($ticketID) $($thisTicket.summary)"
        Update-CWMTicket @ticketOwner | Out-Null
    #    New-CWMScheduleEntry -member @{identifier = "SLim"} -objectId $ticketID -type @{id=4}

        if ($thisTicket.summary.ToString().ToLower().Contains("Server reboot pending after patch installation")) {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 33 # 33 is the type for Type: Server
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 125 # 125 is the subtype for SubType: Update

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("4728")) {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 1817 # 1817 is the type for Type: Server (Zenith Board)
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 9811 # 9811 is the subtype for SubType: Update (Zenith Board)

        } elseif ($thisTicket.summary.ToString().ToLower().Contains("VSS writer(s) is/are in failed status at Site")) {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 35 # 33 is the type for Type: Server (Zenith Board)
            Update-SubType -ticketID $ticketID -summary $thisTicket.summary -subTypeId 833 # 833 is the subtype for SubType: VSS (Zenith Board)

        } elseif ($thisTicket.summary.ToString() -like "* - CONDITION - CPU Utilization is greater than equals threshold") {
            Update-Type -ticketID $ticketID -summary $thisTicket.summary -typeID 1845 #  is the type for Type: Server (System Performance Board)

        }
    }

    Disconnect-CWM
}

main