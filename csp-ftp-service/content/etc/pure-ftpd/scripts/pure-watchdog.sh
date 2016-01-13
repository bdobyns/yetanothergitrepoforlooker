#!/bin/bash -e
# provenance: originally written for the CATS-1349 csp-ftp-service due to CATS-2193 bug / BOLT-690
# blame: bdobyns@productops.com July 2015
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
 
# functions to read and write persistent variables
ME=`basename $0`
if [ '-bash' == "$0" ] ; then
    FTPHOME=/etc/pure-ftpd/scripts
else
    FTPHOME=`dirname $0`
fi
source $FTPHOME/common.sh

# see how long we've been up.
US=`uptime -s`
UP=`uptime -p`
UU=`date -d "$US" "+%s"`
UPSECS=$[ `date "+%s"` - $UU ]
WAITUNTIL=1200

# don't self-terminate unless we've been up for a while (give everything a chance to settle down)
if [ $UPSECS -lt $WAITUNTIL ] ; then
    echo "too early for watchdog to run, need to wait at least $WAITUNTIL secs, $UP" | logger -t csp_ftp_watchdog
    $FTPHOME/statsd-client.sh 'csp-ftp-service.watchdog.TooEarly:1|c'
    exit 0
fi    

# quick check to see if the the watchable sidecar is working and has been initialized
if [ -z "$CSP_FTP_HOMES" ] ; then
    echo "watchable sidecar not up, so we must be very early in startup, $UP" | logger -t csp_ftp_watchdog
    $FTPHOME/statsd-client.sh 'csp-ftp-service.watchdog.NoSidecar:1|c'
    exit 0
fi


# BOLT-690 watchdog if we set the PV to reboot, then we 'shutdown -r now'
# otherwise we try to 'shutdown -P now' which has the effect of terminating the instance
if [ $CSP_FTP_REBOOT_OR_TERMINATE_ON_FAIL == reboot ] || [ $CSP_FTP_REBOOT_OR_TERMINATE_ON_FAIL == Reboot ] ; then
	REBOOT=1
else
	REBOOT=0
fi

# our logic is that we look for the AWS health check probes which happen  
# every 30 seconds, so there should always be some in every minute.
# (the 30 seconds is set inside postinst-part2.sh in the "aws route53 create-health-check" line)
# if we see valid health check probes from the *PREVIOUS MINUTE*, 
# then we know the pure-ftpd daemon is still listening properly

# ubuntu@csp-ftp-service04:~$ D=date -d "now -1 minute" '+%b %e %H:%M' ; tail -1000 /var/log/syslog | grep "$D" | grep "New connection from"
# Jul  8 18:25:05 csp-ftp-service04 pure-ftpd: (?@ec2-54-248-220-39.ap-northeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-248-220-39.ap-northeast-1.compute.amazonaws.com
# Jul  8 18:25:05 csp-ftp-service04 pure-ftpd: (?@ip-10-181-57-226.ec2.internal) [INFO] New connection from ip-10-181-57-226.ec2.internal
# Jul  8 18:25:12 csp-ftp-service04 pure-ftpd: (?@ec2-54-241-32-103.us-west-1.compute.amazonaws.com) [INFO] New connection from ec2-54-241-32-103.us-west-1.compute.amazonaws.com
# Jul  8 18:25:12 csp-ftp-service04 pure-ftpd: (?@ec2-54-183-255-135.us-west-1.compute.amazonaws.com) [INFO] New connection from ec2-54-183-255-135.us-west-1.compute.amazonaws.com
# Jul  8 18:25:12 csp-ftp-service04 pure-ftpd: (?@ec2-107-23-255-7.compute-1.amazonaws.com) [INFO] New connection from ec2-107-23-255-7.compute-1.amazonaws.com
# Jul  8 18:25:13 csp-ftp-service04 pure-ftpd: (?@ec2-54-244-52-199.us-west-2.compute.amazonaws.com) [INFO] New connection from ec2-54-244-52-199.us-west-2.compute.amazonaws.com
# Jul  8 18:25:16 csp-ftp-service04 pure-ftpd: (?@ec2-54-245-168-39.us-west-2.compute.amazonaws.com) [INFO] New connection from ec2-54-245-168-39.us-west-2.compute.amazonaws.com
# Jul  8 18:25:16 csp-ftp-service04 pure-ftpd: (?@ec2-54-255-254-231.ap-southeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-255-254-231.ap-southeast-1.compute.amazonaws.com
# Jul  8 18:25:18 csp-ftp-service04 pure-ftpd: (?@ec2-54-228-16-7.eu-west-1.compute.amazonaws.com) [INFO] New connection from ec2-54-228-16-7.eu-west-1.compute.amazonaws.com
# Jul  8 18:25:20 csp-ftp-service04 pure-ftpd: (?@ec2-54-250-253-231.ap-northeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-250-253-231.ap-northeast-1.compute.amazonaws.com
# Jul  8 18:25:21 csp-ftp-service04 pure-ftpd: (?@ec2-176-34-159-231.eu-west-1.compute.amazonaws.com) [INFO] New connection from ec2-176-34-159-231.eu-west-1.compute.amazonaws.com
# Jul  8 18:25:22 csp-ftp-service04 pure-ftpd: (?@ec2-54-252-79-167.ap-southeast-2.compute.amazonaws.com) [INFO] New connection from ec2-54-252-79-167.ap-southeast-2.compute.amazonaws.com
# Jul  8 18:25:23 csp-ftp-service04 pure-ftpd: (?@ec2-54-252-254-199.ap-southeast-2.compute.amazonaws.com) [INFO] New connection from ec2-54-252-254-199.ap-southeast-2.compute.amazonaws.com
# Jul  8 18:25:26 csp-ftp-service04 pure-ftpd: (?@ec2-54-251-31-135.ap-southeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-251-31-135.ap-southeast-1.compute.amazonaws.com
# Jul  8 18:25:35 csp-ftp-service04 pure-ftpd: (?@ip-10-181-57-226.ec2.internal) [INFO] New connection from ip-10-181-57-226.ec2.internal
# Jul  8 18:25:35 csp-ftp-service04 pure-ftpd: (?@ec2-54-248-220-39.ap-northeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-248-220-39.ap-northeast-1.compute.amazonaws.com
# Jul  8 18:25:42 csp-ftp-service04 pure-ftpd: (?@ec2-54-241-32-103.us-west-1.compute.amazonaws.com) [INFO] New connection from ec2-54-241-32-103.us-west-1.compute.amazonaws.com
# Jul  8 18:25:42 csp-ftp-service04 pure-ftpd: (?@ec2-54-183-255-135.us-west-1.compute.amazonaws.com) [INFO] New connection from ec2-54-183-255-135.us-west-1.compute.amazonaws.com
# Jul  8 18:25:42 csp-ftp-service04 pure-ftpd: (?@ec2-107-23-255-7.compute-1.amazonaws.com) [INFO] New connection from ec2-107-23-255-7.compute-1.amazonaws.com
# Jul  8 18:25:43 csp-ftp-service04 pure-ftpd: (?@ec2-54-244-52-199.us-west-2.compute.amazonaws.com) [INFO] New connection from ec2-54-244-52-199.us-west-2.compute.amazonaws.com
# Jul  8 18:25:46 csp-ftp-service04 pure-ftpd: (?@ec2-54-245-168-39.us-west-2.compute.amazonaws.com) [INFO] New connection from ec2-54-245-168-39.us-west-2.compute.amazonaws.com
# Jul  8 18:25:46 csp-ftp-service04 pure-ftpd: (?@ec2-54-255-254-231.ap-southeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-255-254-231.ap-southeast-1.compute.amazonaws.com
# Jul  8 18:25:49 csp-ftp-service04 pure-ftpd: (?@ec2-54-228-16-7.eu-west-1.compute.amazonaws.com) [INFO] New connection from ec2-54-228-16-7.eu-west-1.compute.amazonaws.com
# Jul  8 18:25:50 csp-ftp-service04 pure-ftpd: (?@ec2-54-250-253-231.ap-northeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-250-253-231.ap-northeast-1.compute.amazonaws.com
# Jul  8 18:25:52 csp-ftp-service04 pure-ftpd: (?@ec2-176-34-159-231.eu-west-1.compute.amazonaws.com) [INFO] New connection from ec2-176-34-159-231.eu-west-1.compute.amazonaws.com
# Jul  8 18:25:53 csp-ftp-service04 pure-ftpd: (?@ec2-54-252-79-167.ap-southeast-2.compute.amazonaws.com) [INFO] New connection from ec2-54-252-79-167.ap-southeast-2.compute.amazonaws.com
# Jul  8 18:25:54 csp-ftp-service04 pure-ftpd: (?@ec2-54-252-254-199.ap-southeast-2.compute.amazonaws.com) [INFO] New connection from ec2-54-252-254-199.ap-southeast-2.compute.amazonaws.com
# Jul  8 18:25:57 csp-ftp-service04 pure-ftpd: (?@ec2-54-251-31-135.ap-southeast-1.compute.amazonaws.com) [INFO] New connection from ec2-54-251-31-135.ap-southeast-1.compute.amazonaws.com

# this gets the time from a minute ago
LASTMIN=`date -d "now -1 minute" '+%b %e %H:%M' `

# this looks for log lines that have the right time signature, pure-ftpd, and the connection string
LINES=`tail -1000 /var/log/syslog | grep "^$LASTMIN" | grep 'pure-ftpd' | grep "New connection from" | wc -l`
if [ $LINES -gt 0 ] ; then
    # saw valid checks, so just statsd-counter and exit
    $FTPHOME/statsd-client.sh 'csp-ftp-service.watchdog.Healthy:1|c'
    exit 0
else
    # did not see valid checks, so this is horrifyingly wrong
    MESSAGE="pure-ftpd did not accept ANY incoming TCP connections (healthcheck probes) at '$LASTMIN', $UP"
    echo "$MESSAGE" | logger -t csp_ftp_watchdog
    HST=`hostname -f`
    INST=`ec2metadata --instance-id`
    REG=`ec2metadata --avalibility-zone  | sed -e 's/.$//'  `   

    if [ $REBOOT -gt 0 ] ; then
        SUBJECT="rebooting $HST, in $SGK_ENV,  instance $INSTANCE, sagoku_deploy_id $SGK_DEPLOY_ID"
	$FTPHOME/statsd-client.sh 'csp-ftp-service.watchdog.Reboot:1|c'
    else
        SUBJECT="terminate $HST, in $SGK_ENV $REG,  instance $INSTANCE, sagoku_deploy_id $SGK_DEPLOY_ID, should automatically redeploy via autoscaling"
	$FTPHOME/statsd-client.sh 'csp-ftp-service.watchdog.Terminate:1|c'
    fi
    echo "$SUBJECT" | logger -t csp_ftp_watchdog
    $FTPHOME/statsd-client.sh 'csp-ftp-service.watchdog.Unhealthy:1|c'

    # call pagerduty
    aws sns publish --message "$MESSAGE" --topic $CSP_FTP_PAGERDUTY_TOPIC --subject "$SUBJECT" | logger -t csp_ftp_watchdog

    # sleep a little for logging and statsd to rattle thru the pipes
    sleep 15
    # shut ourselves down for being broken
    if [ $REBOOT -eq 1 ] ; then 
        # -r reboot, -P power off
        shutdown -r now | logger -t csp_ftp_watchdog
    else
        # turns out we don't have the authority to terminate our own instances
        aws ec2 terminate-instances --instance-ids $INST --region $REG | logger -t csp_ftp_watchdog
	# but shutdown + power-off has the same effect as terminate
        shutdown -P now | logger -t csp_ftp_watchdog
    fi
fi    

exit 0
