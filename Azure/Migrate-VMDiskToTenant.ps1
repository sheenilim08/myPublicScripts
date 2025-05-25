# Credits to https://www.azuredoctor.com/posts/migrating-vms-between-tenants/

# Below are the parameters which will be used.
$source_tenant_id = ""
$source_subscription_id = ""
$source_location = "Central US"
$source_resource_group = "RG-OFTHE-SNAPSHOT-TO-COPY"
$Source_diskforsnapshot_name = "SNAPSHOT-NAME"

$target_tenant_id = ""
$target_subscription_id = ""
$target_location = "Central US"
$target_resource_group = "RG-ON-THE-TARGET-TENANT"
$target_disksnapshot_name = "SNAPSHOT-NAME"


#Login to Azure and get the primary token for the target tenant
Connect-AzAccount -tenant $target_tenant_id
$accessToken = Get-AzAccessToken
$PrimaryToken = $accessToken.Token

#Login to Azure and get the auxiliary token for the source tenant
Connect-AzAccount -Tenant $source_tenant_id
$accessToken = Get-AzAccessToken
$auxilaryToken = $accessToken.Token

#Set up the headers for the REST Call which includes primary token and auxiliary token
$headers = @{
    "Authorization" = "Bearer $PrimaryToken"
    "x-ms-authorization-auxiliary" = "Bearer $auxilaryToken"
    "Content-Type" = "application/json"
    }

#Here we’re specifying the source disk name
 
$diskforsnapbody = @{
    location = $source_location
    properties = @{
    creationdata = @{
        createOption = "Copy"
        sourceResourceId =
        "/subscriptions/$source_subscription_id/resourcegroups/$source_resource_group/providers/Microsoft.Compute/snapshots/$Source_diskforsnapshot_name"
        }
    }

} | ConvertTo-Json -Depth 5

#Here we’re making REST call and providing target subscription as destination however the snapshot source is the source disk from source subscription.

$disksnapresponse = Invoke-RestMethod -Uri `
"https://management.azure.com/subscriptions/$target_subscription_id/resourceGroups/$target_resource_group/providers/Microsoft.Compute/snapshots/$target_disksnapshot_name ?api-version=2024-03-02" `
-Method Put -Headers $headers -Body $diskforsnapbody -ContentType "application/json"