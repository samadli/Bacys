#!/bin/bash
#This is the user interface of Bacys. You are just giving some parameters of configuration and script does your work for you!

echo " ----> NAME OF CONFIGURATION FILE <----"
read CONFIGFILE
echo "Enter the directory which you want to back up"
read BACKUPDIR
echo "Enter the local directory where you'll keep backed up files"
read ARCHIVEDIR
echo "Enter the machine where you'll send backup files"
read MACHINE
echo "Username"
read USERNAME
echo "Enter the directory @ the remote machine where I'll keep your backup files"
read MBACKUPDIR

rm -f $CONFIGFILE
echo $BACKUPDIR >> $CONFIGFILE
echo $ARCHIVEDIR >> $CONFIGFILE
echo $MACHINE >> $CONFIGFILE
echo $USERNAME >> $CONFIGFILE
echo $MBACKUPDIR >> $CONFIGFILE

echo "Do you want to start the backup process? (Y/N)"
read ANSWER
until [[ "$ANSWER" = "y" || "$ANSWER" = "Y" || "$ANSWER" = "n" || "$ANSWER" = "N" ]];
do
	echo "You've entered wrong parameter. Use only y for yes and n for no"
	read ANSWER
done
case $ANSWER in
	"y") bash backup.sh < $CONFIGFILE;;
	"n") echo "Your configuration file has been created";;

esac
exit 0
