@echo off

if not exist %programdata%\2k_backup_log\ md %programdata%\2k_backup_log\

set backuppath=\\ares\winsvrbackups\
set backuplogpath=%programdata%\2k_backup_log\
set restingplace=%backuppath%%computername%

if not exist %restingplace% md %restingplace%

REM Formatting Date and Time

SET HOUR=%time:~0,2%
SET dtStamp9=%date:~-4%%date:~4,2%%date:~7,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%

if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)

set dtStamp=%dtStamp: =%

REM Use dtStamp

REM End Date and Time Formatting
echo ####################################################### > %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## Beginning backup script created by Cameron Snyder ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## cameronsnyder@yahoo.com                           ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ####################################################### >> %backuplogpath%%computername%.%dtStamp%.backup.log

start powershell Get-Content %backuplogpath%%computername%.%dtStamp%.backup.log -Wait

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo Beginning Backup to volume %backuppath% at %time% on %date% >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log

wbadmin start backup -backupTarget:%backuppath% -vssFull -allCritical -systemstate -quiet >> %backuplogpath%%computername%.%dtStamp%.backup.log

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo Archiving to %restingplace%\%computername%.archive.%dtStamp% at %time% on %date% >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log

move %backuppath%WindowsImageBackup\%computername% %restingplace%\%computername%.archive.%dtStamp% >> %backuplogpath%%computername%.%dtStamp%.backup.log

net use x: %restingplace% >> %backuplogpath%%computername%.%dtStamp%.backup.log
FORFILES /p X:\ /S /D -30 /C "cmd /c IF @isdir == TRUE rd /S /Q @path"
net use x: /delete /yes >> %backuplogpath%%computername%.%dtStamp%.backup.log

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo Batch job finished at %time% on %date% >> %backuplogpath%%computername%.%dtStamp%.backup.log

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ####################################################### >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## Ending backup script created by Cameron Snyder    ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## cameronsnyder@yahoo.com                           ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ####################################################### >> %backuplogpath%%computername%.%dtStamp%.backup.log