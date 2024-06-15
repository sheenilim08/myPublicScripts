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

Import-Module 'ConnectWiseManageAPI'

Write-Output "Connecting to CW Endpoint $($CWMConnectionInfo.Server)"
Connect-CWM @CWMConnectionInfo -Force

$closedProfTicket = @(Get-CWMTicket -pageSize 100 -condition '((status/name = "Completed") and (board/name = "Professional Services" or board/name = "Tier 3") and resources = "SLim")')
$closedProfTicketToday = @()

$closedZenithTicket = @(Get-CWMTicket -pageSize 100 -condition '((status/name = "Resolved") and (board/name = "Patching" or board/name = "System Performance" or board/name = "Zenith") and resources = "SLim")')
$closedZenithTicketToday = @()

Disconnect-CWM

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

$closedZenithTicket | ForEach-Object {
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

        $closedZenithTicketToday += $thisTicket
    }
}

Write-Output "Closed Professional Tickets: $($closedProfTicketToday.Count)"
$closedProfTicketToday | Sort-Object lastUpdated | FT id, summary, lastUpdated

Write-Output "Closed Zenith Tickets: $($closedZenithTicketToday.Count)"
$closedZenithTicketToday | Sort-Object lastUpdated | FT id, summary, lastUpdated