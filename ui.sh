#!/bin/bash
#This is the user interface of Bacys. You are just giving some parameters of configuration and script does your work for you!
read_src_folders () {
	echo "Enter the list of directories you want to back up separated by space:"
	read -a SRC_DIR
	declare -a BAD_SRC_DIR
	for dir in "${SRC_DIR[@]}"
	do
		if [ ! -d "$dir" ]
	then
		BAD_SRC_DIR=("${BAD_SRC_DIR[@]}" "$dir")
	fi
	done 
	if [ ${#BAD_SRC_DIR[@]} -gt 0 ]
	then
		echo "The following folders do not exist or can not be read: ${badfldr[@]}"
		echo " $(tput setaf 1) $(tput bold)Please try again $(tput sgr0)"
		read_src_folders
	else
		echo " $(tput setaf 2) OK. All folders are accessible. Next step.. $(tput sgr0)"
	fi
}

read_local_dir () {
	echo "Please enter path to the folder to store backups in:"
	read DST_DIR
	if [ -w $DST_DIR ]
	then
		echo "OK. Folder exists and is writable. Next step.."
	else
		echo "Folder does not exist or is not writable."
		echo "Please try again."
		read_local_dir
	fi
}

read_ftp_cred () {
	read -p "Host address: " FTP_HOST
	read -p "Username: " FTP_USER
	read -s -p "Password: " FTP_PASS; echo
	read -p "Please enter remote directory: " DST_DIR

	#Check provided FTP credentials and folder
	ftp_test=ftp_test_`date +%s`.tmp
	ftp_log=ftp_cred_test.log
	echo "ftp_test" > $ftp_test
	ftp -invp $FTP_HOST << END_FTP > $ftp_log
		user $FTP_USER $FTP_PASS 
		cd $DST_DIR
		put $ftp_test
		del $ftp_test
		bye 
END_FTP
	if grep -q "550 " $ftp_log
	then
		ftp_resp="Failed to change to destination directory"
	elif grep -q "553 " $ftp_log
	then
		ftp_resp="Failed to write to destination folder"
	elif grep -q "226 " $ftp_log
	then
		ftp_resp="FTP check OK"
	elif grep -q "530 " $ftp_log
	then
		ftp_resp="Login incorrect"
	else
		ftp_resp="Can't connect. Check server address"
	fi
	echo $ftp_resp
}

read_scp_cred () {
	read -p "Host address: " SCP_HOST
	read -p "Username: " SCP_USER
	#read -s -p "Password: " SCP_PASS; echo
	read -p "Please enter remote directory: " DST_DIR
	scp_test=scp_test_`date +%s`.tmp
	echo "scp_test" > $scp_test
	scp $scp_test $SCP_USER'@'$SCP_HOST':'$DST_DIR
	if [ $? -ne 0 ]
	then
		echo -e "Error occured.\n"
	else
		echo -e "SCP credentials are OK.\n"
	fi
	rm $scp_test
}

read_dst_option () {
	while :
	do
	echo "Where do you want to store your backups?"
	echo -e "1. Local folder/mount point.\n2. SCP to remote machine.\n3. FTP to remote machine.\n4. RSYNC to remote machine.\n5. SFTP to remote machine.\n"
	read -p "Enter the number of your choice: " BCKOPT
	case $BCKOPT in
		1) read_local_dir; break;;
		2) read_scp_cred; break;;
		3) read_ftp_cred; break;;
		4) echo "Calls function to read rsync options."; break;;
		5) echo "Calls function to read sftp credentials."; break;;
		*) echo "Please enter number in range [1-5]"
	echo "Press Enter to continue. . ."; read ;;
	esac
	done
}

create_backup_script () {
	bkp_nm=backup_`date +%d%m%y`
	i=$((`ls -1 | grep $bkp_nm.*\.sh$ | wc -l`+1))
	bkp_script_name=$bkp_nm"_"$i".sh"
	bkp_file_name=$bkp_nm"_"$i".tar.gz"
	echo "#This is backup script generated by Bacys." > $bkp_script_name
	echo "tar czf "$bkp_file_name" "${SRC_DIR[@]} >> $bkp_script_name
	case $BCKOPT in
		1) echo "mv $bkp_file_name $DST_DIR" >> $bkp_script_name;;
		2) echo "scp $bkp_file_name $SCP_USER'@'$SCP_HOST':'$DST_DIR" >> $bkp_script_name;;
		3) echo -e "ftp -inp $FTP_HOST << END_FTP\nuser $FTP_USER $FTP_PASS\ncd $DST_DIR\nput $bkp_file_name\nbye\nEND_FTP\nrm $bkp_file_name" >> $bkp_script_name;;
		4) echo "Calls function to read rsync options."; break;;
		5) echo "Calls function to read sftp credentials."; break;;
	esac 
	chmod +x $bkp_script_name
}

read_src_folders
read_dst_option
create_backup_script

echo "Do you want to start the backup process? (Y/N)"
read ANSWER
until [[ "$ANSWER" = "y" || "$ANSWER" = "Y" || "$ANSWER" = "n" || "$ANSWER" = "N" ]];
do
	echo "You've entered wrong parameter. Use only y for yes and n for no"
	read ANSWER
done
case $ANSWER in
	[yY]) sh $bkp_script_name;;
	 [nN]) echo "Your configuration file has been created";;

esac