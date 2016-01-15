#!/bin/bash -e
# this script is executed on the TARGET MACHINE after the deb is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

LOOKERHOME=/home/looker

# set the permissions and ownership properly ----------------------------------
chown -R looker:looker $LOOKERHOME
chmod -R +x $LOOKERHOME
# this should not be world-readable
chown -R root:root /etc/letsencrypt

# fix up a startup script -----------------------------------------------------

# this does not work right for startup/shutdown
# but it should allow 
#     service looker status
# to work right (for sagoku healthcheck)

WRAPPER=$LOOKERHOME/scripts/looker-wrapper.sh 
cp $WRAPPER  /etc/init.d/looker
chmod +rx /etc/init.d/looker
update-rc.d looker defaults

# have to run the rest of the install later, 
# since installing the letsencrypt.org client relies on package management
#       waiting two minutes, so the intall of this one runs to completion
echo bash $LOOKERHOME/scripts/postinst-part2.sh | at "now +2 minute"

