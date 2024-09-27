$doNotReboot = [System.Boolean]::Parse($env:doNotReboot)
$shutdown = [System.Boolean]::Parse($env:shutdown)

$logSourceName = "Custom_SourceEventLogSource"
function main() {
  $currentTimeDate = (get-date).ToString('MMM-dd-yyyy_HH-mm-ss')

  $prefferedFileName = "$($env:computername)_$($currentTimeDate)"

  Write-Host "Filename Suffix: '$($prefferedFileName)'"

  Write-Output "Retreiving Services and saving to C:\Windows\System32\pre-reboot-service-status_$($prefferedFileName).csv"
  Get-Service | Select-Object DisplayName, Name, StartType, Status | Export-Csv "pre-reboot-service-status_$($prefferedFileName).csv"
  Get-Service | Select-Object DisplayName, Name, StartType, Status | Export-Csv "pre-reboot-service-status.csv"

  Write-Output "Retreiving network information and saving to C:\Windows\System32\pre-reboot-ipconfig_$($prefferedFileName).csv"
  $nicAdapters = @(Get-NetAdapter -Physical)
  
  $nics = @()
  for ($i=0; $i -lt $nicAdapters.Length; $i++) {
    $adaterInfo = $nicAdapters[$i];
    $nicIPInfo = Get-NetIPConfiguration -InterfaceIndex $adaterInfo.InterfaceIndex

    $currentNicInfo = New-Object -TypeName PSObject
    $currentNicInfo | Add-Member -MemberType NoteProperty -Name InterfaceIndex -Value $adaterInfo.InterfaceIndex
    $currentNicInfo | Add-Member -MemberType NoteProperty -Name InterfaceAlias -Value $adaterInfo.InterfaceAlias
    $currentNicInfo | Add-Member -MemberType NoteProperty -Name MACAddr -Value $adaterInfo.MacAddress
    $currentNicInfo | Add-Member -MemberType NoteProperty -Name IPAddress -Value $nicIPInfo.IPv4Address
    $currentNicInfo | Add-Member -MemberType NoteProperty -Name DNSServers -Value $nicIPInfo.DNSServer[1].ServerAddresses

    $nics += $currentNicInfo
  }

  $nics | Select-Object InterfaceIndex, InterfaceAlias, MACAddr, IPAddress, DNSServers | Export-Csv "pre-reboot-ipconfig_$($prefferedFileName).csv"
  $nics | Select-Object InterfaceIndex, InterfaceAlias, MACAddr, IPAddress, DNSServers | Export-Csv "pre-reboot-ipconfig.csv"

  Write-Host "Retrieving Disk Partition Information and saving to C:\Windows\System32\pre-reboot-partitions_$($prefferedFileName).csv"
  $disks = @(Get-Disk | Select-Object Number, FriendlyName, SerialNumber, HealthStatus, OperationalStatus, TotalSize, PartitionStyle, Path, LogicalSectorSize, PhysicalSectorSize)
  $partionInfo = @()
  for ($i=0; $i -lt $disks.Length; $i++) {
    $currentDisk = $disks[$i];
    $currentParition = @(Get-Partition -DiskNumber $currentDisk.Number | Where-Object { $_.DriveLetter.ToString() -ne "" })

    $currentPartitionInfo = New-Object -TypeName PSObject
    $currentPartitionInfo | Add-Member -MemberType NoteProperty -Name ParentDiskSerialNumber -Value $currentDisk.Number
    $currentPartitionInfo | Add-Member -MemberType NoteProperty -Name PartitionGuid -Value $currentParition.Guid
    $currentPartitionInfo | Add-Member -MemberType NoteProperty -Name IsBoot -Value $currentParition.IsBoot
    $currentPartitionInfo | Add-Member -MemberType NoteProperty -Name IsOffline -Value $currentParition.IsOffline
    $currentPartitionInfo | Add-Member -MemberType NoteProperty -Name Size -Value $currentParition.Size
    $currentPartitionInfo | Add-Member -MemberType NoteProperty -Name Type -Value $currentParition.Type

    $partionInfo += $currentPartitionInfo
  }
  
  $partionInfo | Select-Object ParentDiskSerialNumber, PartitionGuid, IsBoot, IsOffline, Size, Type | Export-Csv "pre-reboot-partitions_$($prefferedFileName).csv"
  $partionInfo | Select-Object ParentDiskSerialNumber, PartitionGuid, IsBoot, IsOffline, Size, Type | Export-Csv "pre-reboot-partitions.csv"


  $logMessage = "Data Collection PreReboot has been saved to:`n"
  $logMessage += "Services: C:\Windows\System32\pre-reboot-service-status.csv`n"
  $logMessage += "IP Config: C:\Windows\System32\pre-reboot-ipconfig.csv`n"
  $logMessage += "Services: C:\Windows\System32\pre-reboot-partitions.csv`n"

  New-EventLog -LogName Application -Source $logSourceName -ErrorAction SilentlyContinue

  if ($shutdown) {
    Write-Host "Shutting down Machine."    
    Write-EventLog –LogName Application –Source $logSourceName –EntryType Warning –EventID 1025  –Message $logMessage
    Start-Sleep -Seconds 10
    Write-EventLog –LogName Application –Source $logSourceName –EntryType Warning –EventID 1025  –Message $logMessage
    Stop-Computer 
  }

  if (!$doNotReboot) {
    Write-Output "Restarting Machine."
    Write-EventLog –LogName Application –Source $logSourceName –EntryType Warning –EventID 1023  –Message $logMessage
    Start-Sleep -Seconds 10
    Write-EventLog –LogName Application –Source $logSourceName –EntryType Warning –EventID 1023  –Message $logMessage
    Restart-Computer -Force
  }
}

try {
  main
} catch {
  Write-Error $_
  exit 2
}