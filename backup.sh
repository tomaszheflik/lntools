#!/bin/bash
trap trap SIGKILL SIGHUP 

SOURCE=/opt/samba_jurxpert/
DEST=/opt/nfs_share/LAN/jurXpert/
#RECIPIENTS=( "biuro@handh.com.pl", "serwis@handh.com.pl", "w.guzdek@kpr.pl" )
RECIPIENTS=( "biuro@handh.com.pl" )


function checkSourceDestination() {
	if [ ! -d "$SOURCE" ]; then
		echo "DEBUG: $SOURCE" 
		exit 1
	fi
	echo "Source $SOURCE is available"

	if [ ! -d "$DEST" ]; then
		echo "DEBUG: $DEST"
		exit 1
	fi
	echo "Destination $DEST is mounted"

}

function doBackup() {
	LOG_FILE=$(mktemp)
	echo "Backup started"
	rsync -arq --log-file=$LOG_FILE $SOURCE $DEST
	if [ $? == 0 ]; then
		echo "Backup SUCCESS. "
		STATUS="SUCCESS"
	else 
		echo "Backup FAILED"
		STATUS="FAILED"
	fi
}

function sendEmail() {
	cp $LOG_FILE /tmp/backup_log.txt
	for RECIPIENT in "${RECIPIENTS[@]}"
	do
		echo "Sending e-mail to: $RECIPIENT"
		echo "Backup $(date) status: Success" | mail -s "$STATUS Backup $(date)" $RECIPIENT \
		-r backup@handh.com.pl \
		-A /tmp/backup_log.txt 
	done
}

function clean() {
	echo "Clean UP"
	rm $LOG_FILE
	rm /tmp/backup_log.txt
}

function trap() {
	echo "Something went wrong. EXIT 1 detected ..."
	exit 1
}

function start() {
	checkSourceDestination
	doBackup
	sendEmail
	clean
	exit 0
}

start
