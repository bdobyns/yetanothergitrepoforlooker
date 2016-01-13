#!/bin/bash -e
# this script is executed on the DEVELOPERS computer
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# deploy.sh

case $1 in
    test|prod)
	set -x
	git push git@git.${1}.cirrostratus.org:repos/looker.git :master
	;;
    *)
	echo "you must specify an environment, and '$1' is not a sensible choice"
	exit 7
	;;
esac
