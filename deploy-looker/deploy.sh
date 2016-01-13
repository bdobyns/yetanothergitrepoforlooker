#!/bin/bash -e
# this script is executed on the DEVELOPERS computer
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# deploy.sh

case $1 in
    test|prod)
	git push git@git.${1}.cirrostratus.org:repos/looker.git
	;;
    *)
	echo "you must specify an environment"
	exit 7
	;;
esac
