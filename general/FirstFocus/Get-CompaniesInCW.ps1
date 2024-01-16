param(
    [switch]$all,
    [ValidatePattern('\S*(desc|asc)')]
    [string]$orderBy,
    [string[]]$companyNames,
    [string]$export
)

$CWMConnectionInfo = @{
    # This is the URL to your manage server.
    Server      = 'na.myconnectwise.net'
    # This is the company entered at login
    Company     = 'sheen'
    # Public key created for this integration
    pubkey      = '1234' # I dont have this
    # Private key created for this integration
    privatekey  = 'abcd' # I dont have this
    # Your ClientID found at https://developer.connectwise.com/ClientID
    clientid    = '6b41981b-8ac6-43ee-8c42-6f44548bba4b'
}

if (Get-InstalledModule 'ConnectWiseManageAPI' -ErrorAction SilentlyContinue) { 
    Update-Module 'ConnectWiseManageAPI' -Verbose 
} else { 
    Install-Module 'ConnectWiseManageAPI' -Verbose 
}

Import-Module 'ConnectWiseManageAPI'

Connect-CWM @CWMConnectionInfo -Force -Verbose

$qualifiedCompanies = $null
if ($all) {
    $qualifiedCompanies = Get-CWMCompany -all
} else {
    $conditionExpression = ""
    for ($i = 0; $i -lt $companyNames.Length; $i++) {
        $conditionExpression += "name CONTAINS `"$($companyNames[$i])`""

        if ($i -ne $companyNames.Length - 1) {
            $conditionExpression += " AND "
        }
    }

    # assuming that the data returned by Get-GWMCompany is JSON similar to the data on https://developer.connectwise.com/Products/ConnectWise_PSA/REST?a=Company&e=Companies&o=GET#/Companies/getCompanyCompanies
    $qualifiedCompanies = Get-CWMCompany -all -condition $conditionExpression
    
    #$qualifiedCompanies = get-content -Raw -Path .\Test.json | ConvertFrom-Json
}

if ($orderBy -eq "desc") {
    $sortedCompanies = $qualifiedCompanies | Sort-Object -Descending
} else {
    $sortedCompanies = $qualifiedCompanies | Sort-Object
}

if ($export) {
    $sortedCompanies | Export-Csv $export
} else {
    $sortedCompanies | Out-GridView
}