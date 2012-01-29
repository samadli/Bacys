#!/bin/bash

read BACKUPDIR

COUNT=$(ls $BACKUPDIR | wc -l)

echo $COUNT

if [[ $COUNT > 30 ]]
then
find $BACKUPDIR -type f -mtime -1 -exec rm -f
fi

exit 0
