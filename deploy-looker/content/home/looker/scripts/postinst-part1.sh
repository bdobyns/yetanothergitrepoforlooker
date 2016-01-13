#!/bin/bash -e
# this script is executed on the TARGET MACHINE
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh


# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

LOOKERSTARTUPSCRIPT=~looker/looker/looker

chmod 0750 $LOOKERSTARTUPSCRIPT
ln -s $LOOKERSTARTUPSCRIPT /etc/init.d/looker
for i in 0 1 2 3 4 5 6
do 
ln -s $LOOKERSTARTUPSCRIPT /etc/rc${i}.d/S87looker
done


# start up the watchable sidecar (see csp-ftp-service)

# start up looker as the right user.
echo sudo -u looker -g looker bash ~/looker/scripts/postinst-part2.sh | at "now +1 minute"

