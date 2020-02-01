#!/bin/bash
#                 SOLA Remove Backups Script (Linux)
#
# Author: Andrew McDowell 
# Date: 04 Mar 2014
# 
# This script deletes backup and log files that are older
# than a specified number of days. This is to avoid old backup
# files using excessive disk space. 
#
# This script should be scheduled to run at least once a day
# using cron. 
# 
# See manual pages for the find command (i.e. man find) for
# details on how to use find for deleting old files. 

# Configure variables to use for script:

# Root directory for the database backups. This is the directory
# mapped withing sola-db to the /home/administrator/sola/backup directory.  
backup_root_dir="/backup/data/"

# Backup directories
hourly_dir=$backup_root_dir"02-hourly"
daily_dir=$backup_root_dir"03-daily"
train_dir=$backup_root_dir"04-train"

# Obtain a formatted date to use in the log file name
datestr=$(date +"%Y%m%d_%H%M")
LOG=$daily_dir"/remove-backups-$datestr.log"
 
# Start the clean
echo
echo 
echo "Starting clean at $(date)"
echo "Starting clean at $(date)" > $LOG 2>&1

# Remove Hourly files older than 2 days
echo "Hourly..." >> $LOG 2>&1
find $hourly_dir -mtime +2 -type f -delete >> $LOG 2>&1

# Remove Daily files older than 14 days
echo "Daily..." >> $LOG 2>&1
find $daily_dir -mtime +14 -type f -delete >> $LOG 2>&1

# Remove Train files older than 4 days
echo "Train..." >> $LOG 2>&1
find $train_dir -mtime +4 -type f -delete >> $LOG 2>&1

# Report the finish time
echo "Finished at $(date)"
echo "Finished at $(date)" >> $LOG 2>&1


