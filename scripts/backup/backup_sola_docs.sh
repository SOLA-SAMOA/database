#!/bin/bash
#                SOLA Documents Backup Script (Linux)
#
# Author: Andrew McDowell 
# Date: 03 Mar 2014
# 
# This script uses the PostgreSQL pg_dump utility to create a backup 
# of documents in the SOLA database. The document table can grow large
# very quickly and a full backup of this table can take several hours.
# To avoid extended backup times, this script supports a partial 
# backup of the documents table by copying all new documents added to 
# SOLA since the last full backup into the document_backup table
# and then runs a backup of that table only. 
#
# The three backup types supported by this script are;
# 
# Full (F)     > Creates a backup of all content in the document.document
#                table. WARNING - This backup may take several hours to
#                complete. It is recommended that full backups occur
#                at regular intervals, e.g. once a month. 
# Partial (P)  > Creates a backup of only those documents that have 
#                been added to the database since the last full 
#                document backup. Note the timestamp for the last
#                full backup is automatically recorded by this 
#                script for use with subsequent partial backups. 
# Training (T) > Much the same as the P backup, but uses a different
#                backup file name to simplify the restore to the 
#                training environment.   
#
# The script will prompt the user (interactive mode) if the -p
# option is provided. The command options recognized are 
#   -p: Prompt the user for other details
#   -t: Type of dump (F, P or T)
#   -f: Frequency of dump (01-Base, 02-Hourly, 03-Daily,  
#       04-Development or 05-Train)
#   -d: Name of the database to dump
#  
# Examples:
# 1) To produce a full backup of the documents table 
#    > ./backup_sola_docs.sh -t F -f 01-Base
# 2) To produce a partial backup of the documents table 
#    > ./backup_sola_docs.sh -t P -f 03-Daily
# 3) To produce a backup for the Training/Test environment 
#    > ./backup_sola_docs.sh -t T -f 05-Train
# 4) To run the script in interactive mode
#    > ./backup_sola_docs.sh -p
# 
# NOTE: This script is dependent on the existence of the 
# document_backup table in the document schema. The
# document_backup table must have the same columns as the
# document table. 
#
# DATABASE PASSWORD
# PGPASSWORD and PGPASSFILE are no longer accepted by
# postgresql so the only way to authenticate with the 
# database is to use a .pgpass file. The .pgpass file
# must be located in the Home directory of the user running
# the script. The script will notify the user and stop if 
# the .pgpass file does not exist.
#
# The format for each line in the .pgpass file is  
#        host:port:database:username:password
# * can be used as a wildcard.  e.g.
#       locahost:5432:*:postgres:<DB Password>
# The .pgpass file must have rw permissions for the user ONLY!
# e.g. chmod 0600 .pgpass


# Restoring the SOLA documents table after an incident
#
# To restore the SOLA documents table, restore the most recent full
# backup into the new database followed by the most recent partial 
# backup. You will also need to manually transfer the documents from
# the document backup table into the document table, 
#


# Configure variables to use for script:

# Root directory for the database backups. This is the directory
# mapped withing sola-db to the /home/administrator/sola/backup directory.  
backup_root_dir="/backup/data/"

# The file to contain the timestamp of the most recent full backup. 
timestamp_file="$backup_root_dir../scripts/backup_docs_timestamp"
year_file="$backup_root_dir../scripts/backup_docs_year"
# Default install location for pg_dump on linux/Debian. This location
# may need to be modified if a different version of postgresql
# is being used and/or it is installed in a custom location.
pg_dump="pg_dump"
pg_restore="pg_restore"
psql="psql"

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

prompt=N
type=P
frequency=03-daily

#Specify the maximum backup file size in MB. Default value is 2GB
max_file_size=2048

# Alter the default timestamp value as required. 
timestamp="26 Jan 2020 05:00"

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
    d) dbname=$OPTARG
       ;;
	p) prompt="Y"
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

# Check if the user should be prompted. 
if [ $prompt == "Y" ]; then
   read -p "What type of backup? - F Full, P Partial, T Training [$type] : " input
   type=${input:-$type}
   read -p "Set frequency subdirectory - 02-Hourly, 03-Daily, etc [$frequency] : " input
   frequency=${input:-$frequency}
fi

# Obtain a formatted date to use in the file names
datestr=$(date +"%Y%m%d_%H%M")

BACKUP_FILE="$backup_root_dir$frequency/sola-docs-$type-$datestr.backup"
BACKUP_LOG="$backup_root_dir$frequency/sola-docs-$type-$datestr.log"
BASE_FOLDER="$backup_root_dir/01-base/"
PGPASS="$HOME/.pgpass"

# Attempt to read the timestamp from the timestamp_file. If the timestamp_file
# does not exist, use the default timestamp value. 
temp=$(head -n 1 $timestamp_file)
timestamp=${temp:-$timestamp}
 
# Start the backup
echo
echo 
echo "Starting Backup at $(date)"
echo "Starting Backup at $(date)" > $BACKUP_LOG 2>&1 
echo "Backup File = $BACKUP_FILE"
echo "Backup File = $BACKUP_FILE" >> $BACKUP_LOG 2>&1

# Determine if the .pgpass file exists.
if [ ! -f  $PGPASS ]; then
   echo "$PGPASS does not exist! - Exiting"
   echo "$PGPASS does not exist! - Exiting" >> $BACKUP_LOG 2>&1
   exit 1
fi

if [ $type == "F" ]; then
   # Dump all records in the document table

   # First create a timestamp to indicate the date/time the last
   # full backup occurred. Do this before the backup runs as it
   # could take several hours during which time new documents may 
   # be added.    
   timestamp=$(date +"%d %b %Y 05:00")
   echo "$timestamp" > $timestamp_file

   echo "Dumping all of the document table..."
   echo "Dumping all of the document table..." >> $BACKUP_LOG 2>&1
   $pg_dump -h $host -p $port -U $username -d $dbname -F c -b -v -w \
            -t document.document -f $BACKUP_FILE >> $BACKUP_LOG 2>&1 

   # Clear the document_backup table using a psql command
   echo "Clearing document_backup..."
   echo "Clearing document_backup..." >> $BACKUP_LOG 2>&1
   $psql -h $host -p $port -U $username -d $dbname -w \
         -c "DELETE FROM document.document_backup;" >> $BACKUP_LOG 2>&1
		 
   # Report the finish time
   echo "Finished at $(date)"
   echo "Finished at $(date)" >> $BACKUP_LOG 2>&1
   exit 0
		 
else
   
   # Copy documents to the document_backup table using a psql command
   echo "Copy to document_backup with timestamp "$timestamp"..."
   echo "Copy to document_backup with timestamp "$timestamp"..." >> $BACKUP_LOG 2>&1
   $psql -h $host -p $port -U $username -d $dbname -w \
         -c "INSERT INTO document.document_backup (id, nr, extension, body, description, rowidentifier, 
                                                   rowversion, change_action, change_user, change_time) 
             SELECT id, nr, extension, body, description, rowidentifier, rowversion, change_action, 
                    change_user, change_time 
             FROM document.document d 
             WHERE d.change_time > '$timestamp'  
             AND NOT EXISTS (SELECT id FROM document.document_backup WHERE id = d.id);" >> $BACKUP_LOG 2>&1

   echo "Dumping document_backup..."
   echo "Dumping document_backup..." >> $BACKUP_LOG 2>&1
    # Dump the content of the document backup table. 
    $pg_dump -h $host -p $port -U $username -d $dbname -F c -b -v -w \
             -t document.document_backup -f $BACKUP_FILE >> $BACKUP_LOG 2>&1  

fi 

if [ $type == "T" ]; then
  # Restore the documents backup to the Training database
  echo "Restoring documents backup..."
  echo "Restoring documents backup..." >> $BACKUP_LOG 2>&1
  $pg_restore -h $train_host -p $train_port -U $train_user -d $train_db -c -j 3 $BACKUP_FILE >> $BACKUP_LOG 2>&1
		
  # Copy documents from the document_backup table using a psql command
  echo "Copy documents from document_backup..."
  echo "Copy documents from document_backup..." >> $BACKUP_LOG 2>&1
  $psql -h $train_host -p $train_port -U $train_user -d $train_db \
	 -c "INSERT INTO document.document (id, nr, extension, body, description, rowidentifier, 
										rowversion, change_action, change_user, change_time) 
		 SELECT id, nr, extension, body, description, rowidentifier, rowversion, change_action, 
				change_user, change_time 
		 FROM document.document_backup db 
		 WHERE NOT EXISTS (SELECT d.id FROM document.document d WHERE d.id = db.id);" >> $BACKUP_LOG 2>&1
fi


backup_file_size=$(du -m $BACKUP_FILE | cut -f1)

if [ $backup_file_size -gt $max_file_size ]; then

   echo "Backup file has exceeded "$max_file_size"MB. Rolling backup..."
   echo "Backup file has exceeded "$max_file_size"MB. Rolling backup..." >> $BACKUP_LOG 2>&1
   echo $(date +"%d %b %Y 05:00") > $timestamp_file
   
   echo "Clearing localhost document_backup..."
   echo "Clearing localhost document_backup..." >> $BACKUP_LOG 2>&1
   $psql -h $host -p $port -U $username -d $dbname -w \
		 -c "DELETE FROM document.document_backup;" >> $BACKUP_LOG 2>&1	

   echo "Clearing "$train_host" document_backup..."
   echo "Clearing "$train_host" document_backup..." >> $BACKUP_LOG 2>&1
   $psql -h $train_host -p $train_port -U $train_user -d $train_db -w \
		 -c "DELETE FROM document.document_backup;" >> $BACKUP_LOG 2>&1	
		 
   echo "Moving backup file to 01-base..."
   echo "Moving backup file to 01-base..." >> $BACKUP_LOG 2>&1
   mv --force $BACKUP_FILE $BASE_FOLDER
   cp --force $BACKUP_LOG $BASE_FOLDER
		 
fi


# Report the finish time
echo "Finished at $(date)"
echo "Finished at $(date)" >> $BACKUP_LOG 2>&1

