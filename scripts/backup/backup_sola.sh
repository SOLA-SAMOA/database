#!/bin/bash
#                       SOLA Backup Script (Linux)
#
# Author: Andrew McDowell 
# Date: 27 Jan 2019
# 
# This script uses the PostgreSQL pg_dump utility to create a backup 
# of the SOLA database. It is a revision of the backup script used for
# SOLA Tonga. 
#
# The backup created is a Main (M) backup that includes all tables 
# except those in the document schema. This is because the documents
# schema is very large (i.e. > 70Gb) and would take many hours to
# backup if included. 
#
# Main (M) > Includes all data except for the _historic tables
# History (H) > Only includes the _historic tables
# Training/Test (T) > Includes all data except the _historic tables and
#       the system.setting table. A second backup is also created that
#       contains the application_historic and service_historic tables.
#       These backups can be restored into the training/test environment.  
#  
# The frequency of the dump can also be indicated by setting the
# name of the subfolder to create the backup in as the third 
# parameter (e.g. 02-Hourly or 03-Daily).  Note that how 
# frequently this script runs is controlled through a scheduled 
# task or cron job.  
#
# The script will prompt the user (interactive mode) if the -p
# option is provided. The command
# options recognized are 
#   -t: Type of dump (M or T)
#   -f: Frequency of dump (01-Base, 02-Hourly, 03-Daily,  
#       or 04-Train)
#   -p: Runs the script in interactive mode
#   -d: Name of the database to dump
#  
# Examples:
# 1) To produce an hourly backup 
#    > docker exec sola-admin bash -c '/backup/scripts/backup_sola.sh'
# 1) To produce a daily backup excluding _historic tables 
#    > docker exec sola-db bash -c '/backup/scripts/backup_sola.sh -f 03-daily'
# 2) To produce a backup for the Training/Test environment 
#    > docker exec sola-db bash -c '/backup/scripts/backup_sola.sh -t T -f 04-train'
# 3) To run the script in interactive mode
#    > docker exec sola-db bash -c '/backup/scripts/backup_sola.sh -p'


# DATABASE PASSWORD
# PGPASSWORD and PGPASSFILE are no longer accepted by
# postgresql so the only way to authenticate with the 
# training database is to use a .pgpass file. The .pgpass file
# must be located in the Home directory of the user running
# the script (i.e. in the sola-db container).
# The script will notify the user and stop if 
# the .pgpass file does not exist.
#
# The format for each line in the .pgpass file is  
#        host:port:database:username:password
# * can be used as a wildcard.  e.g.
#       locahost:5432:*:postgres:<DB Password>
# The .pgpass file must have rw permissions for the user ONLY!
# e.g. chmod 0600 .pgpass


# Configure variables to use for script:

# Root directory for the database backups. This is the directory
# mapped withing sola-db to the /home/administrator/sola/backup directory.  
backup_root_dir="/backup/data/"

# Default install location for pg_dump on linux/Debian. This location
# may need to be modified if a different version of postgresql
# is being used and/or it is installed in a custom location.
# For the sola-db image, pg_dump  and pg_restore are on the path. 
pg_dump="pg_dump"
pg_restore="pg_restore"

# Default DB connection to the local production database
host=localhost
port=5432
dbname=sola_prod
username=postgres

# Default connection values for the Training database
train_host=mnre-sola02
train_port=5432
train_db=sola_prod
train_user=postgres

# Default the script parameters. 
prompt=N
type=M
frequency=02-hourly

# Capture options from the command line
OPTIND=1 # Reset for getopts in case it was used previously.
while getopts "ht:f:pd:" opt; do
  case $opt in
    t) type=$OPTARG
       ;;
    f) frequency=$OPTARG
       ;;
    h) echo "Valid options: -t <type> -f <frequency> -d <database name>" 
       exit 0
       ;;
    p) prompt=Y
       ;;
    d) dbname=$OPTARG
       ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :) echo "Option -$OPTARG requires an argument." >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND-1)) # Shift off the options and optional --.

# Check if the script should run interactively
if [ $prompt == "Y" ]; then
   read -p "What type of backup? - M Main, T Training [$type] : " input
   type=${input:-$type}
   read -p "Set frequency subdirectory - 02-hourly or 03-daily [$frequency] : " input
   frequency=${input:-$frequency}
fi

# Obtain a formatted date to use in the file names
datestr=$(date +"%Y%m%d_%H%M")

BACKUP_FILE="$backup_root_dir$frequency/sola-$type-$datestr.backup"
BACKUP_LOG="$backup_root_dir$frequency/sola-$type-$datestr.log"
PGPASS="$HOME/.pgpass"
 
 # Start the backup
echo
echo 
echo "Starting Backup at $(date)"
echo "Starting Backup at $(date)" > $BACKUP_LOG 2>&1
echo "Backup File = $BACKUP_FILE"
echo "Backup File = $BACKUP_FILE" >> $BACKUP_LOG 2>&1

# Dump all tables except the document schema tables
echo "Dumping Main..."
echo "Dumping Main..." >> $BACKUP_LOG 2>&1

$pg_dump -h $host -p $port -U $username -d $dbname -F c -b -v -N document -f $BACKUP_FILE >> $BACKUP_LOG 2>&1


if [ $type == "T" ]; then 
   # This backup will be restored into training. Check to make sure the .pgpass file
   # exists otherwise the connection to the training database will be rejected. 
   if [ ! -f  $PGPASS ]; then
      echo "$PGPASS does not exist! Unable to restore to training - Exiting"
      echo "$PGPASS does not exist! Unable to restore to training - Exiting" >> $BACKUP_LOG 2>&1
      exit 1
   fi 

   echo "Restoring backup to training server..."
   echo "Restoring backup to training server..." >> $BACKUP_LOG 2>&1
   $pg_restore -h $train_host -p $train_port -U $train_user -c -d $train_db -j 5 $BACKUP_FILE >> $BACKUP_LOG 2>&1
fi

# Report the finish time
echo "Finished at $(date)"
echo "Finished at $(date)" >> $BACKUP_LOG 2>&1