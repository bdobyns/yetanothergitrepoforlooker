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

# looker binary directory needs to be present
LBIN=$LOOKERHOME/looker 
if [ ! -d $LBIN ] ; then 
    echo "ERROR: no $LBIN"
    exit 42
fi 

# the installer needs to have generated SSL keys
# AND needs to have converted those keys to a java keychain
ME=`hostname -f`
SSL=$LOOKERHOME/ssl
LE=/etc/letsencrypt/archive/$ME

# the files in $LE are the ssl certificates
# the files in $SSL are the java keychain pieces for looker
# the files in $LBIN are the looker binaries
for F in  $LE/cert1.pem $LE/privkey1.pem  $SSL/looker.p12  $SSL/looker.jks $SSL/keystorepass $LBIN/looker.jar $LBIN/looker
do
    if [ ! -f $F ] ; then 
	echo "ERROR: no $F"
	exit 42 
    fi
done



cd $LBIN
# start up looker as the right user. ------------------------------------------
if [ -z $USER ] || [ $USER != looker ] ; then 
    sudo su - looker $LBIN/looker $*
else
    $LBIN/looker $*    
fi 
