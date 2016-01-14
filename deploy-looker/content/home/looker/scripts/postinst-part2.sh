#!/bin/bash -e
# this script is executed on the TARGET MACHINE after the deb is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

if [ $UID -eq 0 ] 
then
    exit 42
else
    cd /home/looker/looker
    ./looker start
fi

exit 0
