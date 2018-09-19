!/bin/bash

#----------------------------------------------------------
# Simple moodle backup script
#----------------------------------------------------------
echo "START setup"
# a passphrase for encryption, in order to being able to use almost any special characters use ""
PASSPHRASE="{[YourSuperS3cr&tPassPhr@Here]#()"

# You may hard-code the domain name and AWS S3 Bucket Name here
DOMAIN=
BUCKET_NAME=

# backup path
# where to store the backup file/s
BACKUP_PATH=
if [ ! -d "$BACKUP_PATH" ] && [ "$(mkdir -p $BACKUP_PATH)" ]; then
    echo "BACKUP_PATH is not found at $BACKUP_PATH. The script can't create it, either!"
    echo 'You may want to create it manually'
    exit 1
fi

# log path
LOG_PATH=
if [ ! -d "$LOG_PATH" ] && [ "$(mkdir -p $LOG_PATH)" ]; then
    echo "LOG_PATH is not found at $LOG_PATH. The script can't create it, either!"
    echo 'You may want to create it manually'
    exit 1
fi

LOG_FILE=${LOG_PATH}/backups.log
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin

declare -r aws_cli=`which aws`
declare -r timestamp=$(date +%F_%H-%M-%S)
declare -r script_name=$(basename "$0")

let AUTODELETEAFTER--

echo "END setup"

echo "START db backup"
#  set up all the mysqldump variables
FILE=${MOODLEDATA_PATH}/db-backup-$timestamp.sql
DBSERVER=127.0.0.1
DATABASE=XXX
USER=XXX
PASS=XXX
#  in case you run this more than once a day, remove the previous version of the file
unalias rm     2> /dev/null
rm ${MOODLEDATA_PATH}/db-backup-*  2> /dev/null

#  do the mysql database backup (dump)

# use this command for a database server on a separate host:
#mysqldump --opt --protocol=TCP --user=${USER} --password=${PASS} --host=${DBSERVER} ${DATABASE} > ${FILE}

# use this command for a database server on localhost. add other options if need be.
mysqldump --opt --user=${USER} --password=${PASS} ${DATABASE} > ${FILE}

# (4) gzip the mysql database dump file
gzip $FILE
rm ${FILE}     2> /dev/null

echo "END db backup"
echo "START encryption"

DB_BACKUP_FILE_NAME=${FILE}.gz
ENCRYPTED_DB_BACKUP_FILE_NAME=${BACKUP_PATH}/db-backup-$timestamp.tar.gz.gpg


if [[ $PASSPHRASE != "" ]]; then
    # using symmetric encryption
    # option --batch to avoid passphrase prompt
    # encrypting database dump
    gpg --symmetric --passphrase $PASSPHRASE --batch -o ${ENCRYPTED_DB_BACKUP_FILE_NAME} ${DB_BACKUP_FILE_NAME}
    if [ "$?" != "0" ]; then
        echo; echo 'Something went wrong while encrypting full backup'; echo
        echo "Check $LOG_FILE for any log info"; echo
    else
        echo; echo 'Backup successfully encrypted'; echo
    fi
elif ["$BUCKET_NAME" != ""]; then
    echo "No PASSPHRASE provided!"
    echo "You may want to encrypt your backup before storing them on S3"
    echo "[WARNING]"
    echo "If your data came from Europe check GDPR compliance"
fi

echo "END encryption"
echo "START aws upload"

if [ "$BUCKET_NAME" != "" ]; then
    if [ ! -e "$aws_cli" ] ; then
        echo; echo 'Did you run "pip install aws && aws configure"'; echo;
    fi
    if [[ $PASSPHRASE != "" ]]; then
        $aws_cli s3 cp ${ENCRYPTED_DB_BACKUP_FILE_NAME} s3://$BUCKET_NAME/${DOMAIN}/db-backup/
    else
        $aws_cli s3 cp ${FILE}.gz s3://$BUCKET_NAME/${DOMAIN}/db-backup/
    fi
    if [ "$?" != "0" ]; then
        echo; echo 'Something went wrong while taking offsite backup'; echo
        echo "Check $LOG_FILE for any log info"; echo
    else
        echo; echo 'Offsite backup successful'; echo
    fi
fi


echo "END aws upload"
echo "START cleaning"

find $BACKUP_PATH -type f -mtime +$AUTODELETEAFTER -exec rm {} \;


echo "END cleaning"

echo; echo 'Files backup (without uploads) is done; please check the latest backup in '${BACKUP_PATH}'.';
echo "Full path to the latest backup is ${DB_BACKUP_FILE_NAME}"
echo

