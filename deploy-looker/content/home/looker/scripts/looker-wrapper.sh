#!/bin/bash

### BEGIN INIT INFO
# Provides:          looker
# Required-Start:    ntp nginx $local_fs $remote_fs $network $syslog $named
# Required-Stop:     ntp nginx $local_fs $remote_fs $network $syslog $named
# Should-Start:      
# Should-Stop:       
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the looker.jar service
# Description:       starts looker using start-stop-daemon
### END INIT INFO

LOOKERHOME=/home/looker

# looker binary needs to be present
LOOKERBIN=$LOOKERHOME/looker 
if [ ! -d $LOOKERBIN ] ; then 
    echo "ERROR: no $LOOKERBIN"
    exit 42
fi 

# the letsencrypt.org needs to have generated keys
# we need to have converted those keys to a java keychain
ME=`hostname -f`
SSL=$LOOKERHOME/ssl
LE=/etc/letsencrypt/archive/$ME

for F in  $LE/cert1.pem $LE/fullchain1.pem $LE/privkey1.pem  $SSL/looker.p12  $SSL/looker.jks $SSL/keystorepass
do
    if [ ! -f $F ] ; then 
	echo "ERROR: no $F"
	exit 42 
    fi
done



cd $LOOKERBIN
# start up looker as the right user. ------------------------------------------
if [ -z $USER ] || [ $USER != looker ] ; then 
    sudo su - looker $LOOKERBIN/looker $*
else
    $LOOKERBIN/looker $*    
fi 
