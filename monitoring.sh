#!/bin/bash
#run this script as a cron job
# ---
#MBACKUPDIR-mumkunse bir fayldan oxusun. Butun arxivlerin saxlandigi, storage elementde olan username@myHost:/MBACKUPDIR/
echo "Host:"
read HOSTS
COUNT=1

for myHost in $HOSTS
do
  count=$(ping -c $COUNT $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
  if [ $count=0 ]
   then
   #here will be the processes to do when computers are donw.
   echo "Host : $myHost is down (ping failed) at $(date)" >> monitoring_log
   #myHost iwlemeyen kompdu. Bize lazimdi MBACKUPDIR=myHost adlipap

  fi
done

exit 0