#!/bin/bash
# cats-1349 csp ftp upload server - cats-1382 this cleans up the local filesystem so that we don't fail for lack of space
# blame: bdobyns@productops.com June 2015
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
 
# functions to read and write persistent variables
ME=`basename $0`
if [ '-bash' == "$0" ] ; then
    FTPHOME=/etc/pure-ftpd/scripts
else
    FTPHOME=`dirname $0`
fi
source $FTPHOME/common.sh

# quick check to see if the the watchable sidecar is working and has been initialized
if [ -z "$CSP_FTP_HOMES" ] ; then 
    $FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.error.homesUndefined:1|c'
    exit 0 
elif [ -z $CSP_FTP_FILESYS ] ; then 
    $FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.error.filesysUndefined:1|c'
    exit 0 
elif [ -z $CSP_FTP_FREE_PERCENTAGE ] ; then 
    $FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.error.freePctUndefined:1|c'
    exit 0 
else
    echo "$CSP_FTP_HOMES hourly cleanup - target free $CSP_FTP_FREE_PERCENTAGE"'%' | logger -t csp_ftp_hourly
    $FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.run:1|c'
fi    

# for BOLT-914 we now run this script after every upload.
# NOTE: we could use a lock here in /var/run to make sure only one 
# instance of the cleanup is running at any given time, but this is
# not necessary since even if there's two or more instances running
# we are unlikely to over-clean and delete more files than necessary
# since we re-measure the free space after every single delete

FSSIZE=`df $CSP_FTP_FILESYS | tail -1 | awk '{ print $2 }' `

# get the list of all files in the $CSP_FTP_HOMES tree
# sort the files in reverse chronological order
ls -1tr `find $CSP_FTP_HOMES -type f` | while read OLDEST_FILE
do
    # recalculate the free space
    FSFREE=`df $CSP_FTP_FILESYS | tail -1 | awk '{ print $4 }' `
    PCT_FREE=$[ $FSFREE * 100 / $FSSIZE ]
    if [ $PCT_FREE -gt $CSP_FTP_FREE_PERCENTAGE ] ; then
        # if we have enough free space then just stop
	break 
    else 
	# otherwise remove the oldest remaining file (the one at the top of the list)
	rm -rf $OLDEST_FILE
        echo "$CSP_FTP_FILESYS free disk $PCT_FREE"'%'" less than $CSP_FTP_FREE_PERCENTAGE"'%'" - deleted $OLDEST_FILE" | logger -t csp_ftp_hourly
	$FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.deleteFile:1|c'
    fi
done


# expose the size of the storage
FSSIZE=`df $CSP_FTP_FILESYS | tail -1 | awk '{ print $2 }' `
set_persistentvariable storage-total-1k-blocks $FSSIZE int >/dev/null
$FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.updatepv:1|c'
# expose the size of the free storage
FSFREE=`df /$CSP_FTP_FILESYS | tail -1 | awk '{ print $4 }' `
set_persistentvariable storage-free-1k-blocks $FSFREE int >/dev/null
$FTPHOME/statsd-client.sh 'csp-ftp-service.hourly.updatepv:1|c'

# log our results
FSFREE=`df $CSP_FTP_FILESYS | tail -1 | awk '{ print $4 }' `
PCT_FREE=$[ $FSFREE * 100 / $FSSIZE ]
echo "$CSP_FTP_HOMES hourly cleanup - actual free $PCT_FREE"'%' | logger -t csp_ftp_hourly

# cleanup old garbage from running authscript.sh
( cd /var/tmp ; find . -name auth'*' -type f -mtime +1 -delete )

#eot
