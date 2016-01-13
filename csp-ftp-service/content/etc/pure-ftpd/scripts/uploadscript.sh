#!/bin/bash -e
# provenance: originally written for the CATS-1349 csp-ftp-service
# blame: bdobyns@productops.com June 2015
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# this is called with environment variables
#    UPLOAD_SIZE    size of the file in bytes
#    UPLOAD_UID     numerical uid of owner
#    UPLOAD_GID     numerical gid of owner
#    UPLOAD_USER    login name
#    UPLOAD_GROUP   group name
#    UPLOAD_VUSER   virtual user name
#    UPLOAD_PERMS   octal integer
#    $1             the local path of the upladed file

# get common variables
if [ '-bash' == "$0" ] ; then
    FTPHOME=/etc/pure-ftpd/scripts
else
    FTPHOME=`dirname $0`
fi	
source $FTPHOME/common.sh
ME=`basename $0`

# curl against bolt-service to notify for an upload
BOLT_SERVICE="$CSP_FTP_NOTIFY_SERVICE.apps.$SGK_ENVIRONMENT.$SGK_BASE_DOMAIN"
LOCAL_EID=`grep "^$UPLOAD_USER" /etc/passwd | cut -d : -f 5 `

# fabricate the S3 path
S3FILEPATH=`echo $1 | sed -e "s|$CSP_FTP_HOMES|$CSP_FTP_S3PATH|" -e 's/"/\\"/g' -e '/\\/\\\\/g' `

# copy to S3
aws s3 cp "$1" "$S3FILEPATH"

JSON="{\
        \"upload_user\":\"$UPLOAD_USER\",\
        \"upload_size\":\"$UPLOAD_SIZE\",\
        \"upload_file\":\"$S3FILEPATH\",\
        \"local_eid\": \"$LOCAL_EID\",\
        \"local_uid\":  \"$UPLOAD_UID\",\
        \"local_gid\":  \"$UPLOAD_GID\",\
        \"local_file\": \"$1\"\
    }"

# log to syslog
echo "$JSON" | tr '\n' ' ' | logger -t csp_ftp_upload

# notify the downstream service
curl --silent $BOLT_SERVICE/$CSP_FTP_NOTIFY_ENDPOINT  -X POST -H 'content-type: application/json' -d "$JSON"  | logger -t csp_ftp_upload

# log to statsd
$FTPHOME/statsd-client.sh 'csp-ftp-service.upload.user.'$UPLOAD_USER':1|c'
$FTPHOME/statsd-client.sh 'csp-ftp-service.upload.files:1|c'
$FTPHOME/statsd-client.sh 'csp-ftp-service.upload.bytes:'$UPLOAD_SIZE'|c'


# BOLT-914 CSP FTP Service fulled up with stuff and ran out of space (over 4GB of uploads within an hour)
# to prevent future recurrences of this problem, we now force a run of the cleanup
# script after each upload.   This is safe since if there's plenty of space, nothing happens.
#
# the only possible issue is if an individual uploaded a single file that's more than
# (100 - freepct)% of the size of the filesystem (larger than 3GB), and this could cause 
# the most recent file and all older files to be deleted immediately.
# HOWEVER, even in this edge case, the file has already been copied to S3 at that point
# and the downstream services have already been notified.
echo bash `dirname $0`/hourly-cleanup.sh | at now +1 minutes

#eot
