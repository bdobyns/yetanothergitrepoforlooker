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

# fix up a startup script -----------------------------------------------------

# this does not work right for startup/shutdown
# but it should allow 
#     service looker status
# to work right (for sagoku healthcheck)

cp $LOOKERHOME/scripts/looker-wrapper.sh /etc/init.d/looker
update-rc.d looker defaults

# start up the watchable sidecar (see csp-ftp-service) ------------------------


# reconfigure nginx using the sample ------------------------------------------
# received from Looker http://www.looker.com/docs/setup-and-management/on-prem-install/sample-nginx-config
ME=`hostname -f`
NGC=/etc/nginx/nginx.conf
cp $NGC ${NGC}.save
# right now we don't have ssl certs so we can't use ssl.
# otherwise all we'd have to change is the domain name.
cat $LOOKERHOME/nginx/looker.conf | sed -e s/looker.domain.com/$ME/ -e /listen/s/443/80/ -e /proxy_pass/s/https/http/ -e '/ssl/s/^/#/' >$NGC
service nginx restart

# start up looker as the right user. ------------------------------------------
echo sudo su - looker $LOOKERHOME/scripts/postinst-part2.sh | at "now +1 minute"

exit 0
