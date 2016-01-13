#!/bin/bash -e
# this script is executed on the target machine
# blame: barry@productops.com jan 2016
# BOLT-1611 deply a looker jar via Sagoku
# postinst.sh


# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

chmod 0750 ~looker/looker/looker

# start up the watchable sidecar (see csp-ftp-service)

# start up looker as the right user.
echo sudo -u looker -g looker bash ~/looker/scripts/postinst-part2.sh | at "now +1 minute"

