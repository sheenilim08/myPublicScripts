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

Import-Module 'ConnectWiseManageAPI' | Out-Null

Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
Connect-CWM @CWMConnectionInfo -Force

$myResourceName = "SLim"
$myStartDay = [System.DateTime]::ParseExact([System.DateTime]::Now.AddDays(-1).ToString("yyyy-MM-dd") + "T21:00:00Z", "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
$myEndDay = [System.DateTime]::ParseExact([System.DateTime]::Now.ToString("yyyy-MM-dd") + "T10:00:00Z", "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)


$closedProfTicket = @(Get-CWMTicket -pageSize 100 -condition "((status/name = 'Completed') and (board/name = 'Professional Services' or board/name = 'Tier 3') and resources contains '$($myResourceName)' and _info/lastUpdated >= [$($myStartDay.TolocalTime())] and _info/updatedBy = '$($myResourceName)')")
$closedProfTicketToday = @()

$closedZenithTicket = @(Get-CWMTicket -pageSize 100 -condition "((status/name = 'Resolved') and (board/name = 'Patching' or board/name = 'System Performance' or board/name = 'Zenith') and resources contains '$($myResourceName)' and _info/lastUpdated >= [$($myStartDay.TolocalTime())] and _info/updatedBy = '$($myResourceName)')")
$closedZenithTicketToday = @()

#$myStartDay = [System.DateTime]::ParseExact([System.DateTime]::Now.AddDays(-1).ToString("yyyy-MM-dd") + "T21:00:00Z", "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
#$myEndDay = [System.DateTime]::ParseExact([System.DateTime]::Now.ToString("yyyy-MM-dd") + "T10:00:00Z", "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)

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

#Add-Content -Path "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportFileName)" -Value $closedProfTicket
#Add-Content -Path "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportFileName)" -Value $closedZenithTicketToday

#Get-Content -Path "$($filePath)"
# my open Tickets
$openProfTickets = @(Get-CWMTicket -pageSize 100 -condition "((board/name = 'Tier 3' or board/name = 'Professional Services') and resources contains '$($myResourceName)') and (status/name != 'Ticket Review' and status/name != 'Completed' and status/name != 'Acknowledged System Generated message' and status/name not contains 'Closed')")
$openZenithTickets = @(Get-CWMTicket -pageSize 100 -condition "((board/name = 'Zenith') and resources contains '$($myResourceName)') and (status/name != 'Ticket Review' and status/name  not contains 'Closed' and status/name != 'Resolved' and status/name != 'Acknowledged System Generated message' and  summary not contains 'Managed Desktop Patch')")

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

$updatedTickets = @()
$nonUpdatedTickets = @()

function buildTicketObject($collection, $currentTicket, $ticket_lastupdate_datetime) {
    $this_updated_ticket = New-Object -TypeName PSObject
    $this_updated_ticket | Add-Member -MemberType NoteProperty -Name TicketID -Value $currentTicket.id
    $this_updated_ticket | Add-Member -MemberType NoteProperty -Name Company -Value $currentTicket.company.name
    $this_updated_ticket | Add-Member -MemberType NoteProperty -Name Summary -Value $currentTicket.summary
    $this_updated_ticket | Add-Member -MemberType NoteProperty -Name lastUpdated -Value $ticket_lastupdate_datetime.ToLocalTime()

    return $this_updated_ticket
}

Write-Output "Checking Open Tickets"
$openProfTickets | ForEach-Object {
    $currentTicket = $_

    $ticket_lastupdate_datetime = [System.DateTime]::ParseExact($currentTicket._info.lastUpdated.Tostring(), "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
    $ticket_datecreated_datetime = [System.DateTime]::ParseExact($currentTicket._info.dateEntered.Tostring(), "yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)

    if ($ticket_lastupdate_datetime -ge $myStartDay.ToLocalTime() -and $ticket_lastupdate_datetime -le $myEndDay.ToLocalTime()) {

        Write-Output "Adding $($currentTicket.id) - $($currentTicket.summary) to Updated Ticket list."
        $updatedTickets += buildTicketObject -collection $updatedTickets -currentTicket $currentTicket -ticket_lastupdate_datetime $ticket_lastupdate_datetime.ToLocalTime()
    } else {

        Write-Output "Adding $($currentTicket.id) - $($currentTicket.summary) to NonUpdated Ticket list."
        $nonUpdatedTickets += buildTicketObject -collection $nonUpdatedTickets -currentTicket $currentTicket -ticket_lastupdate_datetime $ticket_lastupdate_datetime.ToLocalTime()
    }

    $thisTicketNotes = Get-CWMTicketNote -TicketId $_.id -condition "(dateCreated >= [$($myStartDay.ToUniversalTime())] and dateCreated <= [$($myEndDay.ToUniversalTime())]) and createdBy == '$($myResourceName)'"
    $thisTicketNotes | Sort-Object dateCreated -Descending | ForEach-Object {
        $currentTicketNote = $_
        if ($currentTicketNote.text -and $currentTicketNote.text.contains("==== TurnOver Notes ====")) {
            $ticket_turnoverinfo = New-Object -TypeName PSObject
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TicketID -Value $currentTicket.id
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name Company -Value $currentTicket.company.name
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TLDRDescription -Value $currentTicketNote.text.split('|')[1]
            $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TurnOverNotes -Value $currentTicketNote.text.split('|')[2]

            $turnOver_tickets += $ticket_turnoverinfo
        }
    }
}

$reportEmail = "$($myResourceName)-$($myStartDay.ToString('MM-dd-yyyy-dddd'))-Report.msg"
$reportFileName = "$($myResourceName)-$($myStartDay.ToString('MM-dd-yyyy-dddd'))-TicketSummary.txt"
$filePath = "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportFileName)"
$emlFilePath = "$($env:USERPROFILE)\OneDrive - Modo Networks\Documents\Scripts\Daily Report\$($reportEmail)"

New-Item -Path $filePath -ItemType File

Write-Output "Updated Professional Tickets: $($updatedTickets.Count)" | Out-File -FilePath "$($filePath)" -Append
$updatedTickets | Sort-Object lastUpdated | FT TicketID, Company, Summary, lastUpdated -AutoSize | Out-File -FilePath "$($filePath)" -Append -Force

Write-Output "NotUpdated Professional Tickets: $($nonUpdatedTickets.Count)" | Out-File -FilePath "$($filePath)" -Append -Force
$nonUpdatedTickets | Sort-Object lastUpdated | FT TicketID, Company, Summary, lastUpdated -AutoSize | Out-File -FilePath "$($filePath)" -Append -Force

Write-Output "Closed Professional Tickets: $($closedProfTicketToday.Count)" | Out-File -FilePath "$($filePath)" -Append -Force
$closedProfTicketToday | Sort-Object lastUpdated | FT id, summary, lastUpdated -AutoSize | Out-File -FilePath "$($filePath)" -Append -Force

Write-Output "Closed Zenith Tickets: $($closedZenithTicketToday.Count)" | Out-File -FilePath "$($filePath)" -Append
$closedZenithTicketToday | Sort-Object lastUpdated | FT id, summary, lastUpdated -AutoSize | Out-File -FilePath "$($filePath)" -Append -Force

Disconnect-CWM

function createTurnOverTickerRow($rowInfo) {
    return '
<tr>
    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;"">
            <span style="font-weight: 500;">' + $rowInfo.TicketId + '</span>
        </div>
    </td>
    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;"">
            <span style="font-weight: 500;">&nbsp;&nbsp;&nbsp;&nbsp;' + $rowInfo.company + '</span>
        </div>
    </td>
    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;"">
            <span style="font-weight: 500;"> &nbsp;&nbsp;&nbsp;&nbsp;' + $rowInfo.TLDRDescription + '</span>
        </div>
    </td>
    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;"">
            <span style="font-weight: 500;">' + $rowInfo.TurnOverNotes.replace("\*", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*").replace("\\", "\").replace("\)", ")").replace("\(", "(").replace("`n", "<br>")  + '</span>
        </div>
    </td>
</tr>
'
}

$turnOver_ticketsHTML = ""

if ($turnOver_tickets.Length -eq 0) {
    $ticket_turnoverinfo = New-Object -TypeName PSObject
    $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TicketID -Value ""
    $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name Company -Value ""
    $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TLDRDescription -Value ""
    $ticket_turnoverinfo | Add-Member -MemberType NoteProperty -Name TurnOverNotes -Value ""

    $turnOver_tickets += $ticket_turnoverinfo
}

$turnOver_tickets | ForEach-Object {
    $turnOver_ticketsHTML += createTurnOverTickerRow -rowInfo $_
}

$emailHtmlBody = '
<html>
    <body>
        <div>
            Open Professional Services: '+ $updatedTickets.Count +'/' + $openProfTickets.Count + ' Updated, ' + $closedProfTicketToday.Count + ' Closed
        </div>
        <div>
            Open Zenith: ' + $openZenithTickets.Count + ' Tickets
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
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); border-left: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;height: 15pt;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">CW Number</span>
                        </div>
                    </td>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">&nbsp;&nbsp;&nbsp;&nbsp;Company</span>
                        </div>
                    </td>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">&nbsp;&nbsp;&nbsp;&nbsp;TLDR Description</span>
                        </div>
                    </td>
                    <td style="direction: ltr; white-space: nowrap; border-top: 0.5pt solid rgb(142, 217, 115); border-right: 0.5pt solid rgb(142, 217, 115); border-bottom: 0.5pt solid rgb(142, 217, 115); background-color: rgb(78, 167, 46); padding-top: 1px; padding-right: 1px; padding-left: 1px; vertical-align: bottom;">
                        <div style="direction: ltr; white-space: nowrap; font-family: Aptos, Aptos_EmbeddedFont, Aptos_MSFontService, Calibri, Helvetica, sans-serif; font-size: 20pt; color: black;">
                            <span style="font-weight: 700;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TurnOver Notes</span>
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
                <br>
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
#$email.To = "overnight@ModoNetworks.Net"
$email.To = "slim@ModoNetworks.Net"
$email.Subject = "Afterhours Turn Over | Sheen | $($myStartDay.ToString("MMMM dd yyyy"))"
$email.HTMLBody = $emailHtmlBody
$email.Attachments.add($filePath)
$email.SaveAs($emlFilePath) # 0 is olTXT format, change it to 5 for olHTML
$email.send()