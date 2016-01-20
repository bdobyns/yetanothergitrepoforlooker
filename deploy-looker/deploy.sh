#!/bin/bash -e
# this script is executed on the DEVELOPERS computer
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# deploy.sh

GIT_BRANCH=` git status | head -1 | awk '{ print $3}' `
ME=`basename $0`

givehelp()
{
cat <<EOF
usage: 
	$ME [env]                  deploy to the given environment
	$ME [env] deploy           deploy to the given environment
	$ME [env] ssh              ssh to the given box
	$ME [env] put file1 file2  copy a file to /home/ubuntu
	$ME [env] get there here   copy a file from /home/ubuntu/there to here
EOF
	exit 7
}

if [ -z $1 ] ; then
    givehelp
    exit
else
    ENV=$1
    # move the args except for the degenerate deploy case
    if [ ! -z $2 ]; then shift ; fi
fi

case $1 in
    test|prod|deploy)
	set -x
	git push git@git.${ENV}.cirrostratus.org:repos/looker.git $GIT_BRANCH:master
	;;
    ssh)
	shift
	set -x
	if [ ! -z $1 ] ; then 
	    ssh ubuntu@looker${1}.${ENV}.cirrostratus.org || ssh ubuntu@looker01.${ENV}.cirrostratus.org || ssh ubuntu@looker02.${ENV}.cirrostratus.org	
	else
	    ssh ubuntu@looker01.${ENV}.cirrostratus.org || ssh ubuntu@looker02.${ENV}.cirrostratus.org 
	fi
	;;
    put)
	shift
	if [ -z $1 ] ; then
	    echo "ERROR - no files to put"
	    givehelp
	else
            set -x
	    scp $* ubuntu@looker01.${ENV}.cirrostratus.org:/home/ubuntu || scp $* ubuntu@looker02.${ENV}.cirrostratus.org:/home/ubuntu
	fi
	;;
    get)
	shift
	if [ -z $1 ] || [ -z $2 ] ; then
	    echo "ERROR - no files to get"
	    givehelp
        else
	    set -x
	    scp ubuntu@looker01.${ENV}.cirrostratus.org:/home/ubuntu/"$1" "$2" || scp ubuntu@looker02.${ENV}.cirrostratus.org:/home/ubuntu/"$1" "$2"
	fi
	;;
    *)
	givehelp
	;;
esac
