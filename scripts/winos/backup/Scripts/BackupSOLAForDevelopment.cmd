@echo off
REM SOLA Samoa Development Backup Script
REM
REM Author: Andrew McDowell 
REM Date: 24 Nov 2012
REM 
REM This script uses the postgres pg_dump utility to create plain
REM backups of the main SOLA Samoa Data tables to support 
REM future development activies. The 7z archive produced by this
REM script can be copied over the default samoa.7z archive used
REM by the SOLA Samoa database build process.  The 7z archive
REM is encrypted to ensure security of the data. 

REM Check the password parameter
set pword=?
set archive_pword=?

IF [%1] EQU [] (
    REM Prompt user for the password if not set
	set /p pword= Database Password [%pword%] :
	set /p archive_pword= Archive Password [%archive_pword%] :
) ELSE (
    set pword=%1
	set archive_pword=%2
)

REM Set location of pg_dump, backup file location and database name
set pg_dump_exe="C:\Program Files\PostgreSQL\9.2\bin\pg_dump" 
set backup_root=E:\Database\Backup\
set backup_file_path=%backup_root%04-Development\
set dropbox_folder=E:\SOLA Deploy\Dropbox\Deploy Files\Database\
set db_name=sola_prod
set BACKUP_LOG="%backup_file_path%out.log"

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

REM get the password from the command line and set the
REM PGPASSWORD environ variable
REM echo pword=%pword%...
SET PGPASSWORD=%pword%

echo Starting backup %time%
echo Starting backup %time% > %BACKUP_LOG% 2>&1

echo Dumping application tables...
echo Dumping application tables... >> %BACKUP_LOG% 2>&1
REM Dump the application tables. Include the application_historic and 
REM service_historic tables so the Lodgement Statistics Report can be tested. 
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t application.application -t application.application_property ^
	-t application.service -t application.application_historic ^
	-t application.service_historic -f "%backup_file_path%08_application.sql" %db_name%  ^
	>> %BACKUP_LOG% 2>&1
	
echo Dumping administrative tables...
echo Dumping administrative tables... >> "%backup_file_path%out.log"
REM Dump the administrative tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t administrative.ba_unit -t administrative.required_relationship_baunit ^
	-t administrative.ba_unit_area -t administrative.rrr -t administrative.rrr_share ^
	-t administrative.party_for_rrr -t administrative.notation ^
	-t administrative.ba_unit_contains_spatial_unit -t administrative.ba_unit_as_party ^
    -t administrative.ba_unit_target ^
	-f "%backup_file_path%07_administration.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping cadastre tables...
echo Dumping cadastre tables... >> "%backup_file_path%out.log"
REM Dump the cadastre tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t cadastre.cadastre_object -t cadastre.spatial_unit ^
	-t cadastre.spatial_value_area -t cadastre.level -t cadastre.spatial_unit_group ^
	-t cadastre.spatial_unit_in_group -t cadastre.cadastre_object_node_target ^
    -t cadastre.cadastre_object_target -t cadastre.spatial_unit_change ^
    -t cadastre.survey_point ^
	-f "%backup_file_path%06_cadastre.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping party tables...
echo Dumping party tables... >> "%backup_file_path%out.log"	
REM Dump the party tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t party.party  -t party.party_role ^
	-f "%backup_file_path%02_party.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping address tables...
echo Dumping address tables... >> "%backup_file_path%out.log"
REM Dump the address tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t address.address  ^
	-f "%backup_file_path%01_address.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping source tables...
echo Dumping source tables... >> "%backup_file_path%out.log"
REM Dump the source tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t source.archive -t source.source -t application.application_uses_source ^
	-t administrative.source_describes_rrr -t source.power_of_attorney ^
    -t administrative.source_describes_ba_unit ^
	-f "%backup_file_path%05_source.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping system tables...
echo Dumping system tables... >> "%backup_file_path%out.log"
REM Dump the system tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t system.appuser -t system.appuser_appgroup -t system.appgroup ^
	-t system.approle_appgroup -t system.approle ^
	-f "%backup_file_path%99_system.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping reference data tables...
echo Dumping reference data tables... >> "%backup_file_path%out.log"
REM Dump the reference data tables tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t system.br -t system.br_definition -t system.br_validation ^
	-t system.config_map_layer -t system.map_search_option ^
    -t system.query -t system.query_field -t system.setting ^
    -t application.request_type -t party.party_type -t source.administrative_source_type ^
	-f "%backup_file_path%99_reference_data.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Dumping transaction tables...
echo Dumping transaction tables... >> "%backup_file_path%out.log"
REM Dump the transaction tables
%pg_dump_exe% -i -h localhost -p 5432 -U postgres -F p -a -b -v ^
    --column-inserts --disable-dollar-quoting --disable-triggers --inserts ^
	-t transaction.transaction -t transaction.transaction_source ^
	-f "%backup_file_path%04_transaction.sql" %db_name% >> %BACKUP_LOG% 2>&1

echo Compressing data...
echo Compressing data... >> "%backup_file_path%out.log"
REM Use 7z to zip the sql files	
"%backup_root%7z.exe"  a "%backup_file_path%samoa.7z"  "%backup_file_path%*.sql" -p%archive_pword% >> %BACKUP_LOG% 2>&1

echo Copying "%backup_file_path%samoa.7z" to "%dropbox_folder%samoa.7z"...
echo Copying "%backup_file_path%samoa.7z" to "%dropbox_folder%samoa.7z"... >> %BACKUP_LOG% 2>&1
copy /B /Y "%backup_file_path%samoa.7z" "%dropbox_folder%samoa.7z" >> %BACKUP_LOG% 2>&1
	
echo Finished at %time%
echo Finished at %time% >> %BACKUP_LOG% 2>&1

	