#!/bin/bash -e -x
# this script is executed on the DEVELOPERS computer
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# deploy.sh

GIT_BRANCH=` git status | head -1 | awk '{ print $3}' `

case $1 in
    test|prod)
	git push git@git.${1}.cirrostratus.org:repos/looker.git $GIT_BRANCH:master
	;;
    ssh)
	ssh ubuntu@looker01.test.cirrostratus.org || ssh ubuntu@looker02.test.cirrostratus.org 
	;;
    put)
	shift
	for i in 01 02
	do
	    if scp $* ubuntu@looker${i}.test.cirrostratus.org:/home/ubuntu
	    then
		break
	    fi
	done
	;;
    get)
	shift
	for i in 01 02
	do
	    if scp ubuntu@looker${i}.test.cirrostratus.org:/home/ubuntu/"$1" "$2"
	    then
		break
	    fi
	done
	;;
    *)
	echo "you must specify an environment, and '$1' is not a sensible choice"
	exit 7
	;;
esac
