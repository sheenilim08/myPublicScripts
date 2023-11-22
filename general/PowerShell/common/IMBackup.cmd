@Echo Off
set TEMPDIR="C:\temp"
mkdir %TEMPDIR%
Echo "backing up imagemanager Registry Keys"
Reg export "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\StorageCraft ImageManager" %TEMPDIR%\ImageManager_Registry_backup.reg"
Echo "Backing up ImageManager DataBase"
copy "C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager.mdb" %TEMPDIR%\Imagemanager.mdb"
set FILESTOZIP=%TEMPDIR%\*"
echo Set objArgs = WScript.Arguments > _zipIt.vbs
echo InputFolder = objArgs(0) >> _zipIt.vbs
echo ZipFile = objArgs(1) >> _zipIt.vbs
echo CreateObject("Scripting.FileSystemObject").CreateTextFile(ZipFile, True).Write "PK" ^& Chr(5) ^& Chr(6) ^& String(18, vbNullChar) >> _zipIt.vbs
echo Set objShell = CreateObject("Shell.Application") >> _zipIt.vbs
echo Set source = objShell.NameSpace(InputFolder).Items >> _zipIt.vbs
echo objShell.NameSpace(ZipFile).CopyHere(source) >> _zipIt.vbs
echo wScript.Sleep 2000 >> _zipIt.vbs
CScript  _zipIt.vbs  %TEMPDIR%  "C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager_Config_backup.zip"
del /Q "%TEMPDIR%\*"
rmdir %TEMPDIR% 
Echo Created C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager_Config_backup.zip
Echo ImageManager Configuration Backup Complete.