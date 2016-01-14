#!/bin/bash -e
# this script is executed on the TARGET MACHINE after the deb is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

LOOKERSTARTUPSCRIPT="/home/looker/looker/looker"

# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

# set the permissions and ownership properly ----------------------------------
chown -R looker:looker /home/looker
chmod +x /home/looker

# fix up a startup script -----------------------------------------------------

# this does not work right for startup/shutdown
# but it should allow 
#     service looker status
# to work right (for sagoku healthcheck)
chmod 0750 $LOOKERSTARTUPSCRIPT
ln -s $LOOKERSTARTUPSCRIPT /etc/init.d/looker
for i in 2 3 5 
do 
ln -s $LOOKERSTARTUPSCRIPT /etc/rc${i}.d/S87looker
done

# start up the watchable sidecar (see csp-ftp-service) ------------------------


# start up looker as the right user. ------------------------------------------
echo sudo -u looker -g looker ~looker/scripts/postinst-part2.sh | at "now +1 minute"

exit 0
