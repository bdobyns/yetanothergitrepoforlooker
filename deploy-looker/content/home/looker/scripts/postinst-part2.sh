#!/bin/bash -e
# this script is executed on the TARGET MACHINE
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# postinst.sh

cd ~looker/looker
./looker start

