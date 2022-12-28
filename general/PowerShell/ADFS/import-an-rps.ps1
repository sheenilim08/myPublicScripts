# This script is not mine, credits goes to KeyFactor.
# Link: https://www.keyfactor.com/blog/migrating-relying-party-trusts/

# Load the ADFS PowerShell snap-in
#Add-PSSnapin Microsoft.Adfs.PowerShell
# Dont add the snapin, run this on the ADFS server instead.

# 1. Open the File exported by the export file on notepad.
# 2. Look for the section 
# <Obj N="Identifier"
# 3. The section should look the below.
# <Obj N="Identifier" RefId="7">
#   <TNRef RefId="3" />
#     <LST>
#       <S>urn:ms-drs:powerdms.achservices.org</S>
#     </LST>
# </Obj>
# 4. copy the <S> value and put it on $rpIdentifier variable

# location where the extracted XML files can be found
$filePathBase = "C:\extract-rp\"

# Identifier of the Relying Party (RP) we want to import
#$rpIdentifier = "urn:federation:identifier.example.com"
$rpIdentifier = "https://identifier.example.com"

# We want the name we created during extract for this so we will try to make the identifier safe
# Replace all of the following characters with a -
#  : " / \ | ? *
$directoryNameSafeIdentifier = $rpIdentifier `
  -replace '', '-' `
  -replace ':', '-' `
  -replace '"', '-' `
  -replace '/', '-' `
  -replace '\\', '-' `
  -replace '\|', '-' `
  -replace '\?', '-' `
  -replace '\*', '-' 	

$xmlFile =  $filePathBase + $directoryNameSafeIdentifier + ".xml"

if (!(Test-Path -path $xmlFile))
{
  "File not found" + $xmlFile
}
else
{
  $ADFSRelyingPartyTrust = Import-clixml $xmlFile
  $NewADFSRelyingPartyTrust = Add-ADFSRelyingPartyTrust -Identifier $rpIdentifier `
    -Name $ADFSRelyingPartyTrust.Name
  $rpIdentifierUri = $NewADFSRelyingPartyTrust.Identifier

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -AutoUpdateEnabled $ADFSRelyingPartyTrust.AutoUpdateEnabled

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -DelegationAuthorizationRules $ADFSRelyingPartyTrust.DelegationAuthorizationRules

  # note we need to do a ToString to not just get the enum number
  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -EncryptionCertificateRevocationCheck `
    $ADFSRelyingPartyTrust.EncryptionCertificateRevocationCheck.ToString()

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
-IssuanceAuthorizationRules $ADFSRelyingPartyTrust.IssuanceAuthorizationRules

  # note we need to do a ToString to not just get the enum number
  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -SigningCertificateRevocationCheck `
    $ADFSRelyingPartyTrust.SigningCertificateRevocationCheck.ToString()

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -WSFedEndpoint $ADFSRelyingPartyTrust.WSFedEndpoint

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -IssuanceTransformRules $ADFSRelyingPartyTrust.IssuanceTransformRules

  # Note ClaimAccepted vs ClaimsAccepted (plural)
  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -ClaimAccepted $ADFSRelyingPartyTrust.ClaimsAccepted

  ### NOTE this does not get imported
  #$ADFSRelyingPartyTrust.ConflictWithPublishedPolicy

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -EncryptClaims $ADFSRelyingPartyTrust.EncryptClaims

  ### NOTE this does not get imported
  #$ADFSRelyingPartyTrust.Enabled

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -EncryptionCertificate $ADFSRelyingPartyTrust.EncryptionCertificate

  # Identifier is actually an array but you can't add it when
  #   using Set-ADFSRelyingPartyTrust -TargetIdentifier
  #   so we use -TargetRelyingParty instead
  $targetADFSRelyingPartyTrust = Get-ADFSRelyingPartyTrust -Identifier $rpIdentifier
  Set-ADFSRelyingPartyTrust -TargetRelyingParty $targetADFSRelyingPartyTrust `
    -Identifier $ADFSRelyingPartyTrust.Identifier

  # SKIP we don't need to import these
  # $ADFSRelyingPartyTrust.LastMonitoredTime
  # $ADFSRelyingPartyTrust.LastPublishedPolicyCheckSuccessful
  # $ADFSRelyingPartyTrust.LastUpdateTime

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -MetadataUrl $ADFSRelyingPartyTrust.MetadataUrl

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -MonitoringEnabled $ADFSRelyingPartyTrust.MonitoringEnabled

  # Name is already done
  #Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
  #  -Name $ADFSRelyingPartyTrust.Name

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -NotBeforeSkew $ADFSRelyingPartyTrust.NotBeforeSkew

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -Notes "$ADFSRelyingPartyTrust.Notes"

  ### NOTE this does not get imported
  #$ADFSRelyingPartyTrust.OrganizationInfo

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -ImpersonationAuthorizationRules $ADFSRelyingPartyTrust.ImpersonationAuthorizationRules

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -ProtocolProfile $ADFSRelyingPartyTrust.ProtocolProfile

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -RequestSigningCertificate $ADFSRelyingPartyTrust.RequestSigningCertificate

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -EncryptedNameIdRequired $ADFSRelyingPartyTrust.EncryptedNameIdRequired

  # Note RequireSignedSamlRequests vs SignedSamlRequestsRequired,
  #Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
  #  -RequireSignedSamlRequests $ADFSRelyingPartyTrust.SignedSamlRequestsRequired
  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -SignedSamlRequestsRequired $ADFSRelyingPartyTrust.SignedSamlRequestsRequired  

  # Note SamlEndpoint vs SamlEndpoints (plural)
  # The object comes back as a
  #   [Deserialized.Microsoft.IdentityServer.PowerShell.Resources.SamlEndpoint]
  #   so we will reconstitute 

  # create a new empty array
  $newSamlEndPoints = @()
  foreach ($SamlEndpoint in $ADFSRelyingPartyTrust.SamlEndpoints)
  {
    # Is ResponseLocation defined?
    if ($SamlEndpoint.ResponseLocation)
    {
      # ResponseLocation is not null or empty
      $newSamlEndPoint = New-ADFSSamlEndpoint -Binding $SamlEndpoint.Binding `
        -Protocol $SamlEndpoint.Protocol `
        -Uri $SamlEndpoint.Location -Index $SamlEndpoint.Index `
        -IsDefault $SamlEndpoint.IsDefault
    }
    else
    {
      $newSamlEndPoint = New-ADFSSamlEndpoint -Binding $SamlEndpoint.Binding `
        -Protocol $SamlEndpoint.Protocol `
        -Uri $SamlEndpoint.Location -Index $SamlEndpoint.Index `
        -IsDefault $SamlEndpoint.IsDefault `
        -ResponseUri $SamlEndpoint.ResponseLocation
    }
    $newSamlEndPoints += $newSamlEndPoint
  }
  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -SamlEndpoint $newSamlEndPoints

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -SamlResponseSignature $ADFSRelyingPartyTrust.SamlResponseSignature

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -SignatureAlgorithm $ADFSRelyingPartyTrust.SignatureAlgorithm

  Set-ADFSRelyingPartyTrust -TargetIdentifier $rpIdentifier `
    -TokenLifetime $ADFSRelyingPartyTrust.TokenLifetime

}

# For comparison testing you can uncomment these lines
#   to export your new import as a ___.XML.new file
# $targetADFSRelyingPartyTrust = Get-ADFSRelyingPartyTrust -Identifier $rpIdentifier
# $filePath = $xmlFile + ".new"
# $AdfsRelyingPartyTrust | Export-Clixml $filePath