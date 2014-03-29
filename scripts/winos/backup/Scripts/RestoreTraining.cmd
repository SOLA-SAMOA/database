@echo off
REM SOLA Samoa Training Restore Script
REM
REM Author: Andrew McDowell 
REM Date: 24 Nov 2012
REM 
REM This script uses the postgres pg_restore utility restore
REM a production backup into the SOLA Samoa Training environment.
REM It does not overwrite the system.appuser or system.setting
REM tables to ensure users can maintain different passwords on 
REM production and training. 
REM 
REM It also restores any new documents added in production to the
REM training documents database to keep them in sync. 
REM
REM This script is not intended to make Training a Hot Backup
REM of production, but simply to keep the data between the two
REM environments relatively in sync. It shoudl be run once a
REM day at most, but can be run on an ad-hoc basis if required. 
REM 
REM Training should not be used to generate lodgement 
REM statistics reports because the restore excludes the 
REM historic data used by the lodgement statistics report
REM 
REM 24 Mar 2014 - Andrew McDowell
REM Updated to restore backup files directly to mnre-sola01
REM without using a shared folder. 

REM Check the password parameter
set pword=?
IF [%1] EQU [] (
    REM Prompt user for the password if not set
	set /p pword= Password [%pword%] :
) ELSE (
    set pword=%1
)

REM Set location of pg_restore and psql executables
set psql_exe="C:\Program Files\PostgreSQL\9.2\bin\psql" 
set pg_restore_exe="C:\Program Files\PostgreSQL\9.2\bin\pg_restore"

REM Set the paths to the backup files. These paths should point to a share 
REM on the Training server that is populated with backups by the BackupSOLA 
REM and BackupSOLADocuments scripts. 
set training_backup_path=E:\Database\Backup\05-Train\
set training_backup=%training_backup_path%training.backup
set training_hist_backup=%training_backup_path%training_hist.backup
set training_docs_backup=%training_backup_path%training_docs.backup

REM Set the database targets
set db_name=sola_train
set db_name_docs=test

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

REM Set the file name for the restore log
set RESTORE_LOG="%training_backup_path%restore_%datestr%.log" 

REM get the password from the command line and set the
REM PGPASSWORD environ variable
REM echo pword=%pword%...
SET PGPASSWORD=%pword%

echo Starting restore %time%
echo Starting restore %time% > %RESTORE_LOG% 2>&1

echo Truncate user table... 
echo Truncate user table... >> %RESTORE_LOG% 2>&1
REM Truncate the user table so that it doesn't duplicate the user details
%psql_exe% --host=mnre-sola01 --port=5432 --username=postgres --dbname=%db_name%  -c "ALTER TABLE system.appuser DISABLE TRIGGER ALL;"  >> %RESTORE_LOG% 2>&1

%psql_exe% --host=mnre-sola01 --port=5432 --username=postgres --dbname=%db_name%  -c "DELETE FROM system.appuser;"  >> %RESTORE_LOG% 2>&1

%psql_exe% --host=mnre-sola01 --port=5432 --username=postgres --dbname=%db_name%  -c "ALTER TABLE system.appuser ENABLE TRIGGER ALL;"  >> %RESTORE_LOG% 2>&1

echo Restoring to %db_name%... 
echo Restoring to %db_name%...  >> %RESTORE_LOG% 2>&1
REM Restore the new production copy of the database		  
%pg_restore_exe% -h mnre-sola01 -p 5432 -U postgres -c -d %db_name% -j 3 %training_backup% >> %RESTORE_LOG% 2>&1

echo Restore history... 
echo Restore history...  >> %RESTORE_LOG% 2>&1
REM Insert any new users from production into training
%pg_restore_exe% -h mnre-sola01 -p 5432 -U postgres -c -d %db_name% -j 3 %training_hist_backup%  >> %RESTORE_LOG% 2>&1


echo Restoring docs to %db_name_docs%... 
echo Restoring docs to %db_name_docs%...  >> %RESTORE_LOG% 2>&1
REM Restore the documents to the document_backup table		  
%pg_restore_exe% -h mnre-sola01 -p 5432 -U postgres -c -d %db_name_docs% -j 3 %training_docs_backup% >> %RESTORE_LOG% 2>&1				  

echo Copy docs to document table... 
echo Copy docs to document table... >> %RESTORE_LOG% 2>&1
REM copy the docs from document_backup into the main document table
%psql_exe% --host=mnre-sola01 --port=5432 --username=postgres --dbname=%db_name_docs%  -c "INSERT INTO document.document (id, nr, extension, body, description, rowidentifier, rowversion, change_action, change_user, change_time) SELECT id, nr, extension, body, description, rowidentifier, rowversion, change_action, change_user, change_time FROM document.document_backup d WHERE NOT EXISTS (SELECT id FROM document.document WHERE id = d.id);"  >> %RESTORE_LOG% 2>&1
	
echo Finished restore at %time%
echo Finished restore at %time% >> %RESTORE_LOG% 2>&1
