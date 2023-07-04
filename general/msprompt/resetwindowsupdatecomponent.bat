Write-Output "Stopping services"
Stop-Service -ServiceName bits
Stop-Service -ServiceName wuauserv
Stop-Service -ServiceName appidsvc
Stop-Service -ServiceName cryptsvc

Write-Output "Deleting '%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat'"
Remove-Item -literalPath "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -force

Write-Output "Renaming Software Distribution Directories"
if (Test-Path -Path "%systemroot%\SoftwareDistribution.bak_byscript") {
  Remove-Item -literalPath "%systemroot%\SoftwareDistribution.bak_byscript" -force -recurse
}

if (Test-Path -Path "%systemroot%\system32\catroot2.bak_byscript") {
  Remove-Item -literalPath "%systemroot%\system32\catroot2.bak_byscript" -force -recurse
}

Rename-Item -Path %systemroot%\SoftwareDistribution -NewName %systemroot%\SoftwareDistribution.bak_byscript
Rename-Item -Path %systemroot%\system32\catroot2 -NewName %systemroot%\system32\catroot2.bak_byscript

Write-Output "Resetting BITS Service Components"
sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)

Write-Output "Reregister BITS Service Components"
cd /d %windir%\system32
regsvr32.exe atl.dll /s
regsvr32.exe urlmon.dll /s
regsvr32.exe mshtml.dll /s
regsvr32.exe shdocvw.dll /s
regsvr32.exe browseui.dll /s
regsvr32.exe jscript.dll /s
regsvr32.exe vbscript.dll /s
regsvr32.exe scrrun.dll /s
regsvr32.exe msxml.dll /s
regsvr32.exe msxml3.dll /s
regsvr32.exe msxml6.dll /s
regsvr32.exe actxprxy.dll /s
regsvr32.exe softpub.dll /s
regsvr32.exe wintrust.dll /s
regsvr32.exe dssenh.dll /s
regsvr32.exe rsaenh.dll /s
regsvr32.exe gpkcsp.dll /s
regsvr32.exe sccbase.dll /s
regsvr32.exe slbcsp.dll /s
regsvr32.exe cryptdlg.dll /s
regsvr32.exe oleaut32.dll /s
regsvr32.exe ole32.dll /s
regsvr32.exe shell32.dll /s
regsvr32.exe initpki.dll /s
regsvr32.exe wuapi.dll /s
regsvr32.exe wuaueng.dll /s
regsvr32.exe wuaueng1.dll /s
regsvr32.exe wucltui.dll /s
regsvr32.exe wups.dll /s
regsvr32.exe wups2.dll /s
regsvr32.exe wuweb.dll /s
regsvr32.exe qmgr.dll /s
regsvr32.exe qmgrprxy.dll /s
regsvr32.exe wucltux.dll /s
regsvr32.exe muweb.dll /s
regsvr32.exe wuwebv.dll /s

Write-Output "Starting Services"
Start-Service -ServiceName bits
Start-Service -ServiceName wuauserv
Start-Service -ServiceName appidsvc
Start-Service -ServiceName cryptsvc