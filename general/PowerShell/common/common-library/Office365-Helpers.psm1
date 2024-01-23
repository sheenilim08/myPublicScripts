function resolveSkuIdToName {
  param (
    [array]
    $SkuIds # The SKU IDs you want to resolve separated by comma as "SkuID1","SkuID2","SKUID3"
  )

  $resolvedSkuIDNames = @()

  foreach ($code in $SkuIds) {
    $resolvedObject = New-Object -TypeName PSObject
    $resolvedObject | Add-Member -MemberType NoteProperty -Name "SkuId" -Value $code
    switch ($code) {
      "f245ecc8-75af-4f8e-b61f-27d8114de5f3" {
        $resolvedObject | Add-Member -MemberType NoteProperty -Name "LicenseName" -Value "Microsoft 365 Business Standard"
      } 
      "3b555118-da6a-4418-894f-7df1e2096870" { 
        $resolvedObject | Add-Member -MemberType NoteProperty -Name "LicenseName" -Value "Microsoft 365 Business Basic"
      } 
      "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82" { 
        $resolvedObject | Add-Member -MemberType NoteProperty -Name "LicenseName" -Value "Exchange Online Kiosk"
      } 
      "a403ebcc-fae0-4ca2-8c8c-7a907fd6c235" { 
        $resolvedObject | Add-Member -MemberType NoteProperty -Name "LicenseName" -Value "Microsoft Fabric"
      }
      "f30db892-07e9-47e9-837c-80727f46fd3d" { 
        $resolvedObject | Add-Member -MemberType NoteProperty -Name "LicenseName" -Value "Microsoft Power Automate Free"
      }
      default {
        $resolvedObject | Add-Member -MemberType NoteProperty -Name "LicenseName" -Value "Unable to resolve Sku Id to License Name"
      }
    }

    $resolvedSkuIDNames += $resolvedObject
  }

  return $resolvedSkuIDNames
}