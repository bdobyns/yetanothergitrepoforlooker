#!/bin/bash
# provenance: originally written for the CATS-1349 csp-ftp-service
# blame: bdobyns@productops.com June 2015
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# always fetch environment variables from sagoku
if [ -f /etc/profile.d/sagoku.sh ] ; then
	. /etc/profile.d/sagoku.sh
fi	

if [ '-bash' == "$0" ] ; then
    FTPHOME=/etc/pure-ftpd/scripts
else
    FTPHOME=`dirname $0`
fi
. $FTPHOME/watchable-lib.sh
 
# by reading these early on (during app startup) we force the local sidecar to initialize them 
#   (with config, if any, which can be slow)
#   so that subsequent reads are quick

export CSP_FTP_HOMES=`persistentvariable csp_ftp_local_base   /mnt/csp/ftp/users`
export CSP_FTP_FILESYS=/`echo $CSP_FTP_HOMES | cut -d / -f 2`
export CSP_FTP_FREE_PERCENTAGE=`persistentvariable csp_ftp_local_free_percentage 25 int`

# note that we changed the bucket to one reserved for this system, see CYP-3579
# this requires a special IAM role to access the bucket is assigned to the app
export CSP_FTP_S3BUCKET=`persistentvariable     csp_ftp_s3_bucket     sequoia-csp-ftp`
# along with CYP-3579 changes, we also changed the path in the bucket to 
# include the app name as well as the environment
export CSP_FTP_S3HOME=`persistentvariable       csp_ftp_s3_path       $SGK_APP/$SGK_ENVIRONMENT/users `
export CSP_FTP_S3PATH=s3://$CSP_FTP_S3BUCKET/$CSP_FTP_S3HOME

export CSP_FTP_NOTIFY_SERVICE=`persistentvariable    csp_ftp_notify_service    bolt-workflow-service `
export CSP_FTP_NOTIFY_ENDPOINT=`persistentvariable   csp_ftp_notify_endpoint   /csp_ftp_notify `
# BOLT-772 change the required role from Publisher to FTP_Partner
export CSP_FTP_REQUIRED_ROLE=`persistentvariable     csp_ftp_required_role     FTP_Partner `

# BOLT-690 watchdog if we set the PV to reboot, then we 'shutdown -r now'
# otherwise we try to 'shutdown -P now' which has the effect of terminating the instance
export CSP_FTP_REBOOT_OR_TERMINATE_ON_FAIL=`persistentvariable     csp_ftp_reboot_or_terminate_on_fail    terminate  `

# this topic was given to us by @nkerr in CATS-2193
# different topics in $TEST and $PROD
if [ $SGK_ENVIRONMENT == prod ] ; then
    export CSP_FTP_PAGERDUTY_TOPIC=`persistentvariable   csp_ftp_pagerduty_topic   "arn:aws:sns:us-east-1:594813696195:cedar-ingestor-validator" `
else
    export CSP_FTP_PAGERDUTY_TOPIC=`persistentvariable   csp_ftp_pagerduty_topic   "arn:aws:sns:us-east-1:594813696195:${SGK_ENVIRONMENT}-cedar" `
fi

# eot
