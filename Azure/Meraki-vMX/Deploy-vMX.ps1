# .\Deploy-vMX.ps1 -subscriptionId "" -resourceGroupName "ps-rg-vmx" -location "southeastasia" -vmxVNetName "ps-vnet-vmx" -vmxVNetAddressSpace "10.0.0.0/16" -vmxSubnetSDWANName "ps-subnet-sdwan" -vmxSubnetSDWANAddressSpace "10.0.254.0/26" -vmxSubnetPRODName "ps-subnet-servers" -vmxSubnetPRODAddressSpace "10.0.0.0/24" -vmxVMName "MerakiVMX" -merakiAuthToken "Token123"
param (
    $subscriptionId,
    $resourceGroupName = "rg-vmx",
    $location = "centralus",
    $vmxVNetName = "vnet-vmx",
    $vmxVNetAddressSpace = "10.0.0.0/16",
    $vmxSubnetPRODName = "subnet-sdwan",
    $vmxSubnetPRODAddressSpace = "10.0.0.0/24",
    $vmxSubnetSDWANName = "subnet-sdwan",
    $vmxSubnetSDWANAddressSpace = "10.0.254.0/26",
    $vmxVMName = "MerakiVMX",
    $merakiAuthToken
)

if ($null -eq $subscriptionId -or "" -eq $merakiAuthToken) {
    Write-Host "Required parameter Subscription ID is missing. Exiting script."
    exit 0;
}

if ($null -eq $merakiAuthToken -or "" -eq $merakiAuthToken) {
    Write-Host "Required parameter Meraki Auth Token is missing. Exiting script."
    exit 0;
}

$azAcctModule = Get-Module Az.Accounts
if ($null -eq $azAcctModule) {
    Write-Host "Installing Az.Resources Module"
    #Install-Module Az.Accounts
    Import-Module Az.Accounts -Force

    # Write-Host "UpdatingAz PS Module"
    # Update-Module -Name Az -Force
}

$azResourcesModule = Get-Module Az.Resources
if ($null -eq $azResourcesModule) {
    Write-Host "Installing Az.Resources Module"
    Import-Module Az.Resources -Force
}

$azNetworkModule = Get-Module Az.Network
if ($null -eq $azNetworkModule) {
    Write-Host "Installing Az.Network Module"
    Import-Module Az.Network -Force
}

Write-Host "Auth to AZ Tenant"
Connect-AzAccount

$rg = @{
    Name = $resourceGroupName
    Location = $location
};

$vnet = @{
    Name = $vmxVNetName
    AddressPrefix = $vmxVNetAddressSpace
    ResourceGroupName = $rg.Name
    Location = $rg.Location
};


function createSetRG {
    param (
        [hashtable]$payload
    )

    $rg_existing = Get-AzResourceGroup -Name $payload.name -ErrorAction SilentlyContinue

    if ($null -ne $rg_existing) {
        Write-Host "Resource Group $($payload.name) already exist."
        return $rg_existing
    }
    Write-Host "Resource Group $($payload.name) is being created."
    return New-AzResourceGroup @payload
}

function createSetVNet {
    param (
        [hashtable]$payload
    )

    $vnet_existing = Get-AzVirtualNetwork -Name $payload.name -ErrorAction SilentlyContinue
    
    if ($null -ne $vnet_existing) {
        Write-Host "VNet $($payload.name) already exist."
        return $vnet_existing
    }

    Write-Host "VNet $($payload.name) - $($payload.addressPrefix) is being created."
    return New-AzVirtualNetwork @payload
}

function createSetSubnet {
    param (
        [hashtable]$payload
    )

    $subnet_existing = Get-AzVirtualNetworkSubnetConfig -Name $payload.name -VirtualNetwork $payload.VirtualNetwork -ErrorAction SilentlyContinue

    if ($null -ne $subnet_existing) {
        Write-Host "Subnet $($payload.name) already exist."
        return $subnet_existing
    }

    Write-Host "Subnet $($payload.name) - $($payload.addressPrefix) is being created."
    Add-AzVirtualNetworkSubnetConfig @payload | Out-Null

    $payload.VirtualNetwork | Set-AzVirtualNetwork | Out-Null # refresh Virtual Network Configuration to reflect Subnets

    return Get-AzVirtualNetworkSubnetConfig -Name $payload.name -VirtualNetwork $payload.VirtualNetwork
}

function createSetNSG {
    param(
        [hashtable]$payload
    )

    $nsg_existing = Get-AzNetworkSecurityGroup -Name $payload.Name -ResourceGroupName $payload.ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -ne $nsg_existing) {
        Write-Host "NSG $($payload.Name) already existing."
        return $nsg_existing
    }

    New-AzNetworkSecurityGroup -ResourceGroupName $payload.ResourceGroupName -Location $payload.Location -Name $payload.Name -SecurityRules $payload.Rule | Out-Null
    return Get-AzNetworkSecurityGroup -Name $payload.Name -ResourceGroupName $payload.ResourceGroupName
}

function createSetNSGRule {
    $ruleName = "vmxAllowAll"

    Write-Host "NSG Rule $($ruleName) is being created."
    return New-AzNetworkSecurityRuleConfig -Name $ruleName -Description "Let vMX Firewall deal with the filtering." `
        -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix Internet `
        -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *
}

function deployManagedApp {
    param([hashtable]$payload)

    $managedApp_existing = Get-AzManagedApplication -ResourceGroup $payload.ResourceGroupName -Name $payload.Name -ErrorAction SilentlyContinue

    if ($null -ne $managedApp_existing) {
        Write-Host "Managed App $($payload.Name) already exist."
        return $managedApp_existing
    }

    Write-Host "Deploying Managed App Cisco Meraki vMX - May take a few minutes to complete. Do not close this window."
    Write-Host "You can check Azure Portal > Resource Group '$($payload.ResourceGroupName)' > Settings > Deployments for the deployment status."

    $templateFile = "template.json"
    New-AzResourceGroupDeployment `
        -Name $payload.Name `
        -ResourceGroupName "$($payload.ResourceGroupName)" `
        -TemplateFile $templateFile `
        -TemplateParameterObject $payload.TemplateParams | Out-Null

    return Get-AzManagedApplication -ResourceGroup $payload.ResourceGroupName -Name $payload.Name
}

function createSetRouteTable {
    param(
        [hashtable]$payload
    )

    $route = New-AzRouteConfig -Name "Route-Google" -AddressPrefix "8.8.8.8/32" -NextHopType "VirtualAppliance" -NextHopIpAddress $payload.VMXLanNIC.IPConfigurations[0].PrivateIpAddress
    New-AzRouteTable -Name "rt-TO-VMX" -ResourceGroupName $payload.ResourceGroupName -Location $payload.Location -Route $route | Out-Null

    return Get-AzRouteTable -Name "rt-TO-VMX" -ResourceGroupName $payload.ResourceGroupName
}

function main() {
    $vmx_rg = createSetRG -payload $rg
    $vmx_vnet = createSetVNet -payload $vnet

    $subnet_sdwan = @{
        Name = $vmxSubnetSDWANName
        VirtualNetwork = $vmx_vnet
        AddressPrefix = $vmxSubnetSDWANAddressSpace
    }

    $subnet_production = @{
        Name = $vmxSubnetPRODName
        VirtualNetwork = $vmx_vnet
        AddressPrefix = $vmxSubnetPRODAddressSpace
    }

    $vmx_subnet_sdwan = createSetSubnet -payload $subnet_sdwan
    $vmx_subnet_production = createSetSubnet -payload $subnet_production

    
    $vmx_managed_rg = createSetRG -payload @{
        Name = "$($vmx_rg.ResourceGroupName)-app"
        Location = $location
    };

    Write-Host "Accepting Azure Market Place EULA - Cisco Meraki VMX"
    Set-AzMarketplaceTerms -Accept -Name "cisco-meraki-vmx" -Product "cisco-meraki-vmx" -Publisher "cisco" | Out-Null
    
    $managedResourceGroupId = "/subscriptions/$($subscriptionId)/resourceGroups/managed-$($vmx_managed_rg.ResourceGroupName)"   

    $appName = "app-$($vmx_rg.ResourceGroupName)"
    Write-Host "App Name: $($appName)"

    $templateParams = @{
        managedResourceGroupId = $managedResourceGroupId
        managedAppName = $appName
        location = $location
        vmName = $vmxVMName
        merakiAuthToken = $merakiAuthToken
        virtualNetworkName = $vmx_vnet.Name
        virtualNetworkAddressPrefix = $vmx_vnet.AddressSpace.AddressPrefixes[0]
        virtualNetworkResourceGroup = $vmx_vnet.ResourceGroupName
        subnetSDWANName = $vmx_subnet_sdwan.Name
        subnetSDWANPrefix = $vmx_subnet_sdwan.AddressPrefix[0]
        subnetPRODName = $vmx_subnet_production.Name
        subnetPRODPrefix = $vmx_subnet_production.AddressPrefix[0]
    }

    # Write-Host "Wait 30 seconds for resources to propagate to Azure System."
    # Start-Sleep -Seconds 30

    $managedApp = deployManagedApp -payload @{
        Name = $appName
        ResourceGroupName = $vmx_managed_rg.ResourceGroupName
        TemplateParams = $templateParams
    }

    # Create NSG
    $nsg_rule_allowAll = createSetNSGRule
    $nsg = createSetNSG -payload @{
        Name = "nsg-$($vmxVMName)"
        Rule = $nsg_rule_allowAll
        ResourceGroupName = $vmx_managed_rg.ResourceGroupName
        Location = $location
    }

    # Apply NSG To Managed VM Nic WAN interface
    Write-Host "Applying NSG to $($vmxVMName)'s $($vmxVMName)WANInterface NIC."
    $vmxNIC = Get-AzNetworkInterface -Name "$($vmxVMName)WANInterface" -ResourceGroup "managed-$($vmx_managed_rg.ResourceGroupName)"
    $vmxNIC.NetworkSecurityGroup = $nsg
    $vmxNIC | Set-AzNetworkInterface # Apply and Refresh Network Interface

    # Create Empty UnAttached Route Table
    $rt = createSetRouteTable -payload @{
        ResourceGroupName = $vmx_managed_rg.ResourceGroupName
        Location = $location
        VMXLanNIC = $vmxNIC
    }

    Write-Host "Please add the routes that should be forwarded to the vMX on the Azure Route Table $($rt.Name)"
    Write-Host "Azure Portal > Virtual Networks > Route Tables > $($rt.Name) > Settings > Routes."
    Write-Host "You should be able to copy the next Hop IP Address for the Google-Route, then click Subnets and attach the Route table to the $($subnet_production.Name). Do not attach the route to $($subnet_sdwan.Name)."
    Write-Host "This part (attaching the route table to the subnet) is deliberately skipped on the script because we cannot predict the future requirement of routing on every Organisation."
}

main