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

if (Get-InstalledModule 'ConnectWiseManageAPI' -ErrorAction SilentlyContinue) { 
    Update-Module 'ConnectWiseManageAPI' -Verbose -Force
} else { 
    Install-Module 'ConnectWiseManageAPI' -Verbose -Force
}

Import-Module 'ConnectWiseManageAPI' | Out-Null

Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
Connect-CWM @CWMConnectionInfo -Force

$closedProfTicket = @(Get-CWMTicket -pageSize 100 -condition '((status/name = "Completed") and (board/name = "Professional Services" or board/name = "Tier 3") and resources = "SLim")')
$closedProfTicketToday = @()

$closedZenithTicket = @(Get-CWMTicket -pageSize 100 -condition '((status/name = "Resolved") and (board/name = "Patching" or board/name = "System Performance" or board/name = "Zenith") and resources = "SLim")')
$closedZenithTicketToday = @()

$myStartDay = [System.DateTime]::ParseExact([System.DateTime]::Now.AddDays(-1).ToString("yyyy-MM-dd") + "T21:00:00Z", "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
$myEndDay = [System.DateTime]::ParseExact([System.DateTime]::Now.ToString("yyyy-MM-dd") + "T10:00:00Z", "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)

Write-Output "Start: $($myStartDay.ToLocalTime())"
Write-Output "End: $($myEndDay.ToLocalTime())"

$closedProfTicket | ForEach-Object {
    $ticket_datetime = [System.DateTime]::ParseExact($_._info.lastUpdated.ToString(), "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)

    # Convert the datetime to local time
    $ticket_lastUpdated = $ticket_datetime.ToLocalTime()

    # check if last update was from today
    if ($ticket_lastUpdated -ge $myStartDay.ToLocalTime() -and $ticket_lastUpdated -le $myEndDay.ToLocalTime() ) {
        # Print the local datetime
        $thisTicket = New-Object -TypeName PSObject
        $thisTicket | Add-Member -MemberType NoteProperty -Name id -Value $_.id
        $thisTicket | Add-Member -MemberType NoteProperty -Name summary -Value $_.summary
        $thisTicket | Add-Member -MemberType NoteProperty -Name lastUpdated -Value $ticket_lastUpdated

        $closedProfTicketToday += $thisTicket
    }
}

$closedZenithP1 = 0
$closedZenithP3 = 0
$closedZenithP4 = 0
$closedZenithTicket | ForEach-Object {
    $ticket_datetime = [System.DateTime]::ParseExact($_._info.lastUpdated.ToString(), "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)

    # Convert the datetime to local time
    $ticket_lastUpdated = $ticket_datetime.ToLocalTime()

    # check if last update was from today
    if ($ticket_lastUpdated -ge $myStartDay.ToLocalTime() -and $ticket_lastUpdated -le $myEndDay.ToLocalTime() ) {
        switch ($_.priority.name) {
            "Priority 1 - Emergency Response" { $closedZenithP1++ }
            "Priority 3 - Normal Response" { $closedZenithP3++ }
            "Priority 4 - Low Impact" { $closedZenithP4++ }

            default { } # do nothing
        }

        # Print the local datetime
        $thisTicket = New-Object -TypeName PSObject
        $thisTicket | Add-Member -MemberType NoteProperty -Name id -Value $_.id
        $thisTicket | Add-Member -MemberType NoteProperty -Name summary -Value $_.summary
        $thisTicket | Add-Member -MemberType NoteProperty -Name lastUpdated -Value $ticket_lastUpdated

        $closedZenithTicketToday += $thisTicket
    }
}

$reportFileName = "$($myStartDay.ToString('MM-dd-yyyy-dddd'))-Closed.txt"
$filePath = "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportFileName)"

New-Item -Path $filePath -ItemType File

#Add-Content -Path "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportFileName)" -Value $closedProfTicket
#Add-Content -Path "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportFileName)" -Value $closedZenithTicketToday

Write-Output "Closed Professional Tickets: $($closedProfTicketToday.Count)" | Out-File -FilePath "$($filePath)"
$closedProfTicketToday | Sort-Object lastUpdated | FT id, summary, lastUpdated -AutoSize | Out-File -FilePath "$($filePath)" -Append

Write-Output "Closed Zenith Tickets: $($closedZenithTicketToday.Count)" | Out-File -FilePath "$($filePath)" -Append
$closedZenithTicketToday | Sort-Object lastUpdated | FT id, summary, lastUpdated -AutoSize | Out-File -FilePath "$($filePath)" -Append

#Get-Content -Path "$($filePath)"
# my open Tickets
$openProfTickets = @(Get-CWMTicket -pageSize 100 -condition "((board/name = 'Tier 3' or board/name = 'Professional Services') and resources contains 'SLim') and (status/name != 'Completed' and status/name not contains 'Closed')")
$openZenithTickets = @(Get-CWMTicket -pageSize 100 -condition "((board/name = 'Zenith') and resources contains 'SLim') and (status/name  not contains 'Closed' and status/name != 'Resolved') and  summary not contains 'Managed Desktop Patch'")

$openZenithP1 = 0
$openZenithP3 = 0
$openZenithP4 = 0
$openZenithTickets | ForEach-Object {
    # check if last update was from today
    switch ($_.priority.name) {
        "Priority 1 - Emergency Response" { $openZenithP1++ }
        "Priority 3 - Normal Response" { $openZenithP3++ }
        "Priority 4 - Low Impact" { $openZenithP4++ }

        default { } # do nothing
    }
}

$turnOver_tickets = @()

$openProfTickets | ForEach-Object {
    $currentTicket = $_
    $thisTicketNotes = Get-CWMTicketNote -TicketId $_.id -condition "(dateCreated >= [$($myStartDay.ToUniversalTime())] and dateCreated <= [$($myEndDay.ToUniversalTime())]) and createdBy == 'SLim'"
    $thisTicketNotes | Sort-Object dateCreated -Descending | ForEach-Object {
        $currentTicketNote = $_
        if ($currentTicketNote.text -or $currentTicketNote.text.contains("==== TurnOver Notes ====")) {
            $ticket_turnoverinfo = New-Object -TypeName PSObject
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TicketID -Value $currentTicket.id
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name Company -Value $currentTicket.company.name
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TLDRDescription -Value $currentTicketNote.text.split('|')[1]
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TurnOverNotes -Value $currentTicketNote.text.split('|')[2]

            $turnOver_tickets += $ticket_turnoverinfo
        }
    }
}

Disconnect-CWM

function createTurnOverTickerRow($rowInfo) {
    return '
<tr>
    <td>
        <div>' + $rowInfo.TicketId + '</div>
    </td>
    <td>
        <div>' + $rowInfo.company +' </div>
    </td>
    <td>
        <div>' + $rowInfo.TLDRDescription + '</div>
    </td>
    <td>
        <div>' + $rowInfo.TurnOverNotes + '</div>
    </td>
</tr>
'
}

$turnOver_ticketsHTML = ""

$turnOver_tickets | ForEach-Object {
    $turnOver_ticketsHTML += createTurnOverTickerRow -rowInfo $_
}

$emailHtmlBody = '
<html>
    <body>
        <div>
            Professional Services: '+ $openProfTickets.Count +'/' + $openProfTickets.Count + ' Updated, ' + $closedProfTicketToday.Count + ' Closed
        </div>
        <div>
            Zenith: ' + $openZenithTickets.Count + ' Tickets
        </div>
            <ul>
                <li>
                    <span>0/' + $openZenithP1 + ' P1s Updated, ' + $closedZenithP1 + ' Closed<br></span>
                </li>
                <li>
                    <span>0/' + $openZenithP3 + ' P3s Updated, ' + $closedZenithP3 + ' Closed<br></span>
                </li>
                <li>
                    <span>0/' + $openZenithP4 + ' P4s Updated, ' + $closedZenithP4 + ' Closed<br></span>
                </li>
            </ul>
        <div>
            <br>
        </div>
        <div>Turnovers and things to look out in the morning:</div>
        <table style="direction: ltr; width: 1482pt; box-sizing: border-box; border-collapse: collapse; border-spacing: 0px; color: inherit; background-color: inherit;" id="table_0">
            <tbody>
                <tr>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); border-left: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom; width: 75pt; height: 15pt;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">CW Number</span>
                        </div>
                    </td>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom; width: 210pt;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">Company</span>
                        </div>
                    </td>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom; width: 313pt;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">Description</span>
                        </div>
                    </td>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-right: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom; width: 884pt;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">Turn-Over Notes</span>
                        </div>
                    </td>
                </tr>' + $turnOver_ticketsHTML + '
            </tbody>
        </table>
        
        <div style="direction: ltr; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">&nbsp;</div>
        <div id="x_Signature" class="x_elementToProof" style="color: inherit;background-color: inherit;"></div>
        <div style="direction: ltr; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 12pt; color: rgb(0, 0, 0);">
            <br>
        </div>
        <div id="x_Signature" style=3D"color: inherit; background-color: inherit;">
            <p style=3D"background-color: white; margin-top: 0px; margin-bottom: 0px;">
                <span style="font-size: 20pt; color: black;">
                    Sheen Ismhael Lim
                </span>
            </p>
            <p style=3D"background-color: white; margin-top: 0px; margin-bottom: 0px;">
                <span style="color: black;">
                    Modo Networks, LLC<br>
                    Support: 214-299-8580<br>
                    Main: 214-299-8040 x123
                </span>
            </p>
            <p style="margin-top: 0px; margin-bottom: 0px;">&nbsp;</p>
        </div>
    </body>
</html>
'


$outlook = new-object -comobject outlook.application

$email = $outlook.CreateItem(0)
$email.To = ""
$email.Subject = "Afterhours Turn Over | $($myStartDay.ToString("MMMM dd yyyy"))"
$email.HTMLBody = $emailHtmlBody
$email.Attachments.add($filePath)
$email.send()