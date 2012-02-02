#!/bin/bash

sudo -k
NOW=$(date +'%F')
read BACKUPDIR
read ARCHIVEDIR
read MACHINE
read USERNAME
read MBACKUPDIR

tar -czf $ARCHIVEDIR/$NOW.tar $BACKUPDIR
ARCHIVE=$ARCHIVEDIR/$NOW.tar
sudo gzip $ARCHIVE

if [[ $? == 0 ]]; then
	echo "Everything is Okay"
fi
#You need ssh public key to complete this action. So, please follow the instruction: http://wiki_page_of_ssh_key_setting_up
scp $ARCHIVE.gz $USERNAME'@'$MACHINE':'$MBACKUPDIR



exit 0
