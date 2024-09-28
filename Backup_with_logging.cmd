@echo off

:: * Begin credit block *
::
:: Written by Cameron Snyder - 2k@rogueangel2k.com
:: You may modify this file as you see fit but
:: leave this credit block intact please.
::
:: Inspiration for my projects are due to my
:: supportive wife, without whom my dreams would
:: just be dreams. This project and all others are
:: dedicated to my wife and son.
::
:: I love you both more than words can express.
::
:: Thank you
::
:: * End credit block *

:: Assumes that Windows Server Back Up is installed
:: Tested on Windows Server 2012 R2, server 2016 and 2019 without issue.
:: GUI not required.

:: Run as scheduled task or right click and run as administrator

:: Set these variables to anything you like
:: Caution... here be dragons.

:: Word of experience with this script.
:: For some reason it performs best when any type of path
:: has a trailing backslash after it.
:: Keep that in mind.
::
:: Example \\servername\sharename\ or c:\temp\folder\
:: Carry on.

:: Sets where your backups will be stored while the routine runs
set backuppath=\\place_destination_server_name_here\place_share_name_here\

:: This sets the log path and if it doesn't exist it will be created
:: You can make this anything you like.

set backuplogpath=%programdata%\backup_log\
if not exist %backuplogpath% md %backuplogpath%

:: Sets where your backups will be moved to after the routine ends
:: If it doesn't exist it will be created

set restingplace=%backuppath%%computername%
if not exist %restingplace% md %restingplace%

:: *** Main script begins **

:: Begin Date and Time Formatting
:: I borrowed this from somewhere online and adapted it to my liking.
:: I honestly do remember where. If I find it again in the future, I'll add credit.

SET HOUR=%time:~0,2%
SET dtStamp9=%date:~-4%%date:~4,2%%date:~7,2%_0%time:~1,1%%time:~3,2%%time:~6,2% 
SET dtStamp24=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%

if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)

set dtStamp=%dtStamp: =%

:: Use dtStamp
:: End Date and Time Formatting

:: Begin first log entries
:: The format of the logfile can be see after the greater than sign
echo ####################################################### > %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## Beginning backup script created by Cameron Snyder ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## cameronsnyder@yahoo.com                           ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ####################################################### >> %backuplogpath%%computername%.%dtStamp%.backup.log

:: Using powershell to follow or tail the current log file
start powershell Get-Content %backuplogpath%%computername%.%dtStamp%.backup.log -Wait

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo Beginning Backup to volume %backuppath% at %time% on %date% >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log

:: Calling wbadmin to start a backup
:: You can add extra parameters if you like
:: Like with the variables above... here be dragons
::
:: wbadmin MS Doc https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/wbadmin-start-backup
wbadmin start backup -backupTarget:%backuppath% -vssFull -allCritical -systemstate -quiet >> %backuplogpath%%computername%.%dtStamp%.backup.log

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo Archiving to %restingplace%\%computername%.archive.%dtStamp% at %time% on %date% >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log

:: After wbadmin finishes and releases everything and assuming all went well
:: we move files from the backup path, or the working directory to a final
:: resting place where 30 days of files will be held
move %backuppath%WindowsImageBackup\%computername% %restingplace%\%computername%.archive.%dtStamp% >> %backuplogpath%%computername%.%dtStamp%.backup.log

:: Modify this to fit your needs... this script assumes a network location
:: and in order to get the forfiles loop below to work, a drive letter had to be used.
:: I chose X.

net use x: %restingplace% >> %backuplogpath%%computername%.%dtStamp%.backup.log
:: Delete anything in the resting place older than 30 days
FORFILES /p X:\ /S /D -30 /C "cmd /c IF @isdir == TRUE rd /S /Q @path"
:: Delete x drive
net use x: /delete /yes >> %backuplogpath%%computername%.%dtStamp%.backup.log

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo Batch job finished at %time% on %date% >> %backuplogpath%%computername%.%dtStamp%.backup.log

echo. >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ####################################################### >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## Ending backup script created by Cameron Snyder    ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ## cameronsnyder@yahoo.com                           ## >> %backuplogpath%%computername%.%dtStamp%.backup.log
echo ####################################################### >> %backuplogpath%%computername%.%dtStamp%.backup.log
