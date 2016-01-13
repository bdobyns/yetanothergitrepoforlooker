#!/bin/bash
# provenance: originally written for the CATS-1349 csp-ftp-service
# blame: bdobyns@productops.com June 2015
set -x

# get common variables
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ME=`basename $0`

# environment variables from sagoku
if [ -f /etc/profile.d/sagoku.sh ] ; then
	. /etc/profile.d/sagoku.sh
fi	

# CONFIG ======================================================================
PUREFTPD=/etc/pure-ftpd
# set our configuration variables for pureftpd
PUREFTPDCONF=$PUREFTPD/conf
echo 0  >$PUREFTPDCONF/DisplayDotFiles
echo 0  >$PUREFTPDCONF/UnixAuthentication
echo 0  >$PUREFTPDCONF/PAMAuthentication
echo 1  >$PUREFTPDCONF/NoAnonymous
echo 1  >$PUREFTPDCONF/NoChmod
echo 1  >$PUREFTPDCONF/ChrootEveryone
echo 1  >$PUREFTPDCONF/CreateHomeDir
echo 1  >$PUREFTPDCONF/CallUploadScript
echo 1000 >$PUREFTPDCONF/MaxClientsNumber
# echo 30000 50000 >$PUREFTPDCONF/PassivePortRange
echo 30000 31000 >$PUREFTPDCONF/PassivePortRange
if [ ! -f $PUREFTPDCONF/ExtAuth ] ; then echo /var/run/ftpd.sock >$PUREFTDCONF/ExtAuth ; fi

chmod 0755 $PUREFTPDCONF
chmod 0644 $PUREFTPDCONF/*
chmod -R 0755 $PUREFTPD/scripts

# no other auth methods but ExtAuth script
rm -rf $PUREFTPD/auth/*
( cd $PUREFTPD/auth ; ln -s ../conf/ExtAuth 10ext )

# START PURE-FTPD ======================================================================
killall pure-authd
# happier if we start the pure-authd separately and first
/usr/sbin/pure-authd -r $PUREFTPD/scripts/authscript.sh -s /var/run/ftpd.sock -B

service pure-ftpd restart

killall pure-uploadscript
# must start the pure-uploadscript separately:  uid/gid 1000/1000 is ubuntu
/usr/sbin/pure-uploadscript -r $PUREFTPD/scripts/uploadscript.sh -g 1000 -u 1000 -B

# CRONTAB ======================================================================
# setup the crontab job(s)
ROOT_CRONTAB=$PUREFTPD/${SGK_APP}.root.crontab
crontab -l | grep -v pure-ftpd >$ROOT_CRONTAB
echo " " >>$ROOT_CRONTAB
echo "# written by $SGK_APP  $0 on "`date` >>$ROOT_CRONTAB
echo '13 * * * * '"$PUREFTPD/scripts/hourly-cleanup.sh" >>$ROOT_CRONTAB
echo '*  * * * * '"$PUREFTPD/scripts/pure-watchdog.sh" >>$ROOT_CRONTAB
cat $ROOT_CRONTAB | crontab

# WATCHABLE SIDECAR ======================================================================
# start the watchable sidecar
# this takes less than three minutes on an M3.MEDIUM to fully start up
export WATCHABLE_SIDECAR=$PUREFTPD/scripts/watchable-sidecar.jar
if [ ! -f $WATCHABLE_SIDECAR ] ; then
    (
	cd `dirname $WATCHABLE_SIDECAR`
	aws s3 cp s3://sequoia-install/watchable-sidecar.jar ${WATCHABLE_SIDECAR}
	echo 'server.port = 8080' >application.properties
	zip $WATCHABLE_SIDECAR application.properties
    )
fi
if [  -f $WATCHABLE_SIDECAR ] ; then
    WSLOG=/mnt/var/log/watchable-sidecar
    if [ -f $WSLOG ] ; then rm -rf $WSLOG ; fi
    mkdir -p $WSLOG
    chown ubuntu $WSLOG
    ln -s $WSLOG /var/log/watchable-sidecar
    # execute as a lower-privilege user. 
    JAVAARGS="-Djava.net.preferIPv4Stack=true -Djava.security.egd=file:/dev/./urandom -server -Xms128m -Xmx256m"
    su ubuntu -c "java $JAVAARGS -jar $WATCHABLE_SIDECAR 2>&1 | tee $WSLOG/watchable-sidecar.log | logger -t 'watchable-sidecar' " &
fi

# PERSISTENT-VARAIBLES ============================================================
echo bash `dirname $0`/postinst-part2.sh | at now +2 minutes

# move namer-exec route53 setup to end of postinst-part2.sh
