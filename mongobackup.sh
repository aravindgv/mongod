#!/bin/bash

#Author:Aravind G V <aravind.gv@gmail.com>
ToAddress="aravind.gv@gmail.com"
tmpFileName="/tmp/mongo_status.txt"

export TZ=Asia/Calcutta
scriptDir=`dirname ${0}`
scriptName=`basename ${0}`
if [ ${scriptDir} = "." ]; then
    scriptDir=`pwd`
fi

scriptSignature(){
      scriptSign="${scriptDir}/${scriptName}"
      echo "####################################################################################################"
      echo "Script Signature: `uname -n`: ${scriptSign}"
      echo "####################################################################################################"
}

DT=$(/bin/date +%Y-%m-%d)
BACKUPPATH=/app/backup/
filename=$BACKUPPATH/$DT
echo -e "\nCreating Mongo DUMP:$filename" >> ${tmpFileName}
mongodump -h localhost  -u xxxx -p xxxx  -o $filename

rc=$?
if [[ $rc != 0 ]] ; then
    /bin/mail -s "[FAILED]MongoDB Backup Failed " ${ToAddress} < $rc
    exit $rc
fi

echo -e "\nMongo DUMP:$filename created Successfully @ $(date +"%T"). Now Arching it" >> ${tmpFileName}
tar -czf $BACKUPPATH/$DT.tar.gz $filename
echo -e "\nBackup Completed @ $(date +"%T")  Backup Path:$BACKUPPATH/$DT.tar.gz \n" >> ${tmpFileName}
rm -rf $filename

rc=$?
if [[ $rc != 0 ]] ; then
    /bin/mail -s "[FAILED]MongoDB Backup Failed during arching " ${ToAddress} < $rc
    exit $rc
fi

if [ -s ${tmpFileName} ]; then
   scriptSignature >> ${tmpFileName}
   /bin/mail  -s "[SUCCESS] MongoDB backup Completed " ${ToAddress} < ${tmpFileName}
fi
rm -f ${tmpFileName}
unset TZ
