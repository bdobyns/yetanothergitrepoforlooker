#!/bin/bash
# provenance: originally written for the CATS-1349 csp-ftp-service
# blame: bdobyns@productops.com June 2015
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
 
# functions to read and write persistent variables
if [ '-bash' == "$0" ] ; then
    FTPHOME=/etc/pure-ftpd/scripts
else
    FTPHOME=`dirname $0`
fi
source $FTPHOME/watchable-lib.sh

# wait till the watchable sidecar is working 
#    -- typically two minutes or so          
PUBLIC_IPV4=`ec2metadata --public-ipv4`
while true
do
    ATTEMPT=`set_persistentvariable test-pv-$$ $PUBLIC_IPV4`
    if [ -z $ATTEMPT ] ; then sleep 15
    elif [ "$ATTEMPT" == "$PUBLIC_IPV4" ] ; then break ; fi
    sleep 15
done

# read the persistent variables from config
source $FTPHOME/common.sh

# create statuslights for our external IP address
# QA can use appname.apps.$ENV.$DOMAIN/watchable/persistentvariab le/public-ipv4 to get an ip address for testing
for LIGHT in public-ipv4 public-hostname local-hostname local-ipv4 instance-type
do
        set_persistentvariable  $LIGHT `ec2metadata --$LIGHT`  >/dev/null
	$FTPHOME/statsd-client.sh 'csp-ftp-service.install.createpv:1|c'
#       set_statuslight $LIGHT `ec2metadata --$LIGHT`
done

# expose the size of the storage
FSSIZE=`df $CSP_FTP_FILESYS | tail -1 | awk '{ print $2 }' `
set_persistentvariable storage-total-1k-blocks $FSSIZE int >/dev/null
$FTPHOME/statsd-client.sh 'csp-ftp-service.install.createpv:1|c'
# expose the size of the free storage
FSFREE=`df /$CSP_FTP_FILESYS | tail -1 | awk '{ print $4 }' `
set_persistentvariable storage-free-1k-blocks $FSFREE int >/dev/null
$FTPHOME/statsd-client.sh 'csp-ftp-service.install.createpv:1|c'

# this must happen after watchable sidecar is working
# because it requires that we've loaded PV's so we can know the value of $CSP_FTP_HOMES
# which might have been loaded from configuration, and not the default value
if [ ! -z $CSP_FTP_HOMES ] ; then 
	mkdir -p $CSP_FTP_HOMES
fi

# deprecated
# /usr/bin/s3fs -d -o iam_role -o allow_other -o default_acl="private" -o use_cache=${CSP_FTP_S3CACHE} ${CSP_FTP_S3BUCKET} ${CSP_FTP_HOMES}

# --MESSING--AROUND--WITH--DNS--AND--ROUTE53----------------------------------------
# do this here at the end of part2, instead of at the end of postinst-part1, 
# so that we're sure we are completely up and available befpre DNS points here
FQDN=`/bin/hostname -f `
IP=`ec2metadata --public-ipv4`
# make sure there's no rules in place for my env:hostname (maybe from an old broken instance)
aws route53 list-health-checks | jq '.HealthChecks[] | select(.HealthCheckConfig.FullyQualifiedDomainName == "'$FQDN'").Id' | tr -d '"' | while read ID
do
    aws route53 delete-health-check --health-check-id $ID
    $FTPHOME/statsd-client.sh 'csp-ftp-service.install.route53.deleteByFqdn:1|c'
done
# make sure there's no rules in place for my ip address (how could this ever happen?)
aws route53 list-health-checks | jq '.HealthChecks[] | select(.HealthCheckConfig.IPAddress == "'$IP'").Id' | tr -d '"' | while read ID
do
    aws route53 delete-health-check --health-check-id $ID
    $FTPHOME/statsd-client.sh 'csp-ftp-service.install.route53.deleteByIp:1|c'
done

# create a rule for this instance
REF=`date "+%Y%m%d%H%M%s"`
# CFG="IPAddress=$IP,Port=21,Type=TCP,RequestInterval=30,FailureThreshold=5"
# note that changing the RequestInterval=30 to a larger value can break the pure-watchdog.sh script, which see.
CFG="Port=21,Type=TCP,RequestInterval=30,FailureThreshold=5,FullyQualifiedDomainName=$FQDN"
# create the healthcheck here, and capture the ID
HCID=`aws route53 create-health-check --caller-reference $REF  --health-check-config $CFG | jq '.HealthCheck.Id' | tr -d '"' `
$FTPHOME/statsd-client.sh 'csp-ftp-service.install.route53.createHealthCheck:1|c'

TAG="$SGK_ENVIRONMENT":`/bin/hostname`
# tag the healthcheck with the env:hosthame
aws route53 change-tags-for-resource --resource-type healthcheck --resource-id $HCID --add-tags Key=Name,Value=$TAG
$FTPHOME/statsd-client.sh 'csp-ftp-service.install.route53.tagHealthCheck:1|c'

EC2NAME=`ec2metadata --public-hostname`
R53NAME=`/bin/hostname | sed 's/[0-9]*$//'`.$SGK_ENVIRONMENT.$SGK_BASE_DOMAIN.
# namer-exec, route 53 setup  ============================================================ (per zzhu) this does not work
# /usr/bin/java -cp /root/namer-exec.jar org.ithaka.sequoia.util.ReregisterWithRoute53 `/bin/hostname` $SGK_ENVIRONMENT $SGK_BASE_DOMAIN `/bin/hostname | sed 's/[0-9]*$//'` / 21

# instead of trying to use the namer-exec, insert/update the resource record directly
RESREC=/tmp/route53resourcerecord.json
cat >$RESREC <<EOF
{
  "Comment": "$0 $REF",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "HealthCheckId": "$HCID",
        "Name": "$R53NAME",
        "Weight": 100,
        "Type": "CNAME",
        "ResourceRecords": [
          {
            "Value": "$EC2NAME"
          }
        ],
        "TTL": 60,
        "SetIdentifier": "$FQDN"
      }
    }
  ]
}

EOF

# this actually updates the route53 resource record and conncects the healthcheck to the hostname.
aws route53 change-resource-record-sets --hosted-zone-id Z2L6YB9WUHJHB5 --change-batch file://$RESREC >/tmp/route53changeresult.json
$FTPHOME/statsd-client.sh 'csp-ftp-service.install.route53.createResourceRecord:1|c'
