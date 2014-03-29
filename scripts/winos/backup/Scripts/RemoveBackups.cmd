@echo off
REM SOLA Samoa Documents Backup Script
REM
REM Author: Andrew McDowell 
REM Date: 24 Nov 2012
REM 
REM This script is used to remove any old backup files that are no 
REM longer relevent. For detailed usage of the forfiles command
REM use forfiles /? from a command prompt.
REM 
REM 24 Mar 2014 - Andrew McDowell
REM Updated to restore backup files directly to mnre-sola01
REM without using a shared folder.

set sharePword=?
IF [%1] EQU [] (
    REM Prompt user for the password if not set
	set /p sharePword= Restore file share password [%sharePword%] :
) ELSE (
    set sharePword=%1
	)
)

SET backup_file_path=E:\Database\Backup\
SET hourly_backups="%backup_file_path%02-Hourly" 
SET daily_backups="%backup_file_path%03-Daily" 
SET training="%backup_file_path%05-Train" 

REM Deletes any files older than 2 days from todays date
forfiles /P %hourly_backups%  /M *.backup /D -2 /C "cmd /c del @PATH"
forfiles /P %hourly_backups%  /M *.log /D -2 /C "cmd /c del @PATH" 

REM Deletes any files older than 7 days from todays date
forfiles /P %daily_backups%  /M *.backup /D -7 /C "cmd /c del @PATH"
forfiles /P %daily_backups%  /M *.log /D -7 /C "cmd /c del @PATH"
forfiles /P %daily_backups%  /M *.sql /D -7 /C "cmd /c del @PATH"

REM Deletes any restore log files older than 7 days from todays date
forfiles /P %training%  /M *.log /D -7 /C "cmd /c del @PATH"