@echo off
REM SOLA Samoa Backup Script
REM
REM Author: Andrew McDowell 
REM Date: 24 Nov 2012
REM 
REM This script uses the postgres pg_dump utility to create a backup 
REM of the SOLA Samoa database. It can create 3 different dumps;
REM 
REM Main (M) > Includes all data except for the _historic tables
REM History (H) > Only includes the _historic tables
REM Training (T) > Includes all data except the _historic tables and
REM       dumps the system.appuser table separately. This backup
REM       can be restored into the training environment without
REM       overwritting user passwords. 
REM  
REM The frequency of the dump can also be indicated by setting the
REM name of the subfolder to create the backup in as the third 
REM parameter (e.g. 02-Hourly or 03-Daily).  
REM 
REM The _historic tables are backed up separately to try and ensure the
REM backup for the main SOLA tables remains small so that the backup
REM can run very quickly  (i.e. < 1 minute). 
REM  
REM Examples:
REM 1) To produce an hourly backup excluding _historic tables 
REM    > BackupSOLA.cmd <password> M 02-Hourly
REM 2) To produce a backup containing ONLY _historic tables 
REM    > BackupSOLA.cmd <password> H 03-Daily
REM 3) To produce a backup for the Training environment 
REM    > BackupSOLA.cmd <password> T 03-Daily
REM
REM Note that the output from the training backup will be copied 
REM automatically to a shared folder on the Training server for
REM immediate restore. 
REM 
REM 
REM Restoring the SOLA database after an incident
REM
REM To restore the SOLA database, create an empty database and restore the 
REM latest M backup file )(from the 02-Hourly folder) followed by a 
REM restore of the latest H backup (from the 03-Daily folder). 
REM Note that this may result in some lost history records depending 
REM on how frequently the historic backup is run. 
REM
REM This script should be scheduled to run as a Windows task to ensure
REM regular backups of the main SOLA Samoa production database. It can
REM also run interactively and will prompt for password and backup type
REM 
REM 24 Mar 2014 - Andrew McDowell
REM Updated to restore backup files directly to mnre-sola01
REM without using a shared folder.

REM Check the password parameter
set pword=?
set type=M
set frequency=02-Hourly
set sharePword=?
IF [%1] EQU [] (
    REM Prompt user for the password if not set
	set /p pword= Password [%pword%] :
	set /p type= What type of backup - M Main, H History, T Training [%type%] :
	set /p frequency= Set frequency subdirectory - 02-Hourly or 03-Daily [%frequency%] :
        set /p sharePword= Restore file share password [%sharePword%] :
) ELSE (
    set pword=%1
	IF [%2] NEQ [] (
	   set type=%2
	)
	IF [%3] NEQ [] (
	   set frequency=%3
	)
	IF [%4] NEQ [] (
	   set sharePword=%4
	)
)

REM Set location of pg_dump, backup file location and database name
set pg_dump_exe="C:\Program Files\PostgreSQL\9.2\bin\pg_dump" 
set base_backup_dir=E:\Database\Backup\
REM R: should be a share to the D:\Restore directory on MNRE-SOLA01
set training_backup="%base_backup_dir%05-Train\training.backup"
set training_hist_backup="%base_backup_dir%05-Train\training_hist.backup"
set db_name=sola_prod

REM Parse out the current date and time
for /f "tokens=1-4 delims=/ " %%i in ("%date%") do (
 set dow=%%i
 set month=%%j
 set day=%%k
 set year=%%l
)

set hr=%TIME: =0%
set hr=%hr:~0,2%
set min=%TIME:~3,2%

set datestr=%year%%month%%day%_%hr%%min%

REM Set the file names
set BACKUP_FILE="%base_backup_dir%%frequency%\sola_%type%_%datestr%.backup"
set BACKUP_LOG="%base_backup_dir%%frequency%\sola_%type%_%datestr%.log"
set BACKUP_FILE_HIST="%base_backup_dir%%frequency%\sola_%type%_hist_%datestr%.sql"

REM get the password from the command line and set the
REM PGPASSWORD environ variable
REM echo pword=%pword%...
SET PGPASSWORD=%pword%


echo Starting backup %time%
echo Starting backup %time% > %BACKUP_LOG% 2>&1
echo Backup File=%BACKUP_FILE%
echo Backup File=%BACKUP_FILE% >> %BACKUP_LOG% 2>&1

IF [%type%] EQU [H] (
	echo Dump History...
    echo Dump History... >> %BACKUP_LOG% 2>&1
	
	%pg_dump_exe% -i -h localhost -p 5432 -U postgres ^
                  -F c -b -v -N lrs -N samoaview -t *.*_historic -f ^
				  %BACKUP_FILE% %db_name% >> %BACKUP_LOG% 2>&1
	
) ELSE (
    IF [%type%] EQU [T] (
		echo Dump Training...
		echo Dump Training... >> %BACKUP_LOG% 2>&1 
		REM Needs to be on one line as the continuation character ^ causes issues for pg_dump when interperting the -T values
		REM Includes the application_historic and service_historic tables so the lodgement report can be accurately generated. 
		%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F c -b -v -N lrs -N samoaview -N document -T system.setting -T *.*_historic -f %BACKUP_FILE% %db_name% >> %BACKUP_LOG% 2>&1

		echo Dump History Tables...
		echo Dump History Tables... >> %BACKUP_LOG% 2>&1 	
		REM Dump a plain text copy of the history tables used by the Lodgement Report
		%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F c -b -v ^
		 			-t application.application_historic -t application.service_historic ^
					-f %BACKUP_FILE_HIST% %db_name% >> %BACKUP_LOG% 2>&1	
					
		echo Moving backups to %training_backup%...
		echo Moving backups to %training_backup%... >> %BACKUP_LOG% 2>&1
		move /Y %BACKUP_FILE% %training_backup% >> %BACKUP_LOG% 2>&1
	    move /Y %BACKUP_FILE_HIST% %training_hist_backup% >> %BACKUP_LOG% 2>&1
		
	) ELSE (
	    REM Run the dump excluding history tables. Also exclude
		REM the lrs and samoaview schema's as the data in these
		REM schema's does not change. 
		echo Dumping Main...
		echo Dumping Main... >> %BACKUP_LOG% 2>&1
		%pg_dump_exe% -i -h localhost -p 5432 -U postgres ^
					  -F c -b -v -N lrs -N samoaview -N document -T *.*_historic -f ^
					  %BACKUP_FILE% %db_name% >> %BACKUP_LOG% 2>&1 
					 
	)
)

echo Finished at %time%
echo Finished at %time% >> %BACKUP_LOG% 2>&1
