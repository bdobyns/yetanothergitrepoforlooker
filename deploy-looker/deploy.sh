#!/bin/bash -e -x
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
	$0 [env]                  deploy to the given environment
	$0 [env] deploy           deploy to the given environment
	$0 [env] ssh              ssh to the given box
	$0 [env] put file1 file2  copy a file to /home/ubuntu
	$0 [env] get there here   copy a file from /home/ubuntu/there to here
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
	git push git@git.${1}.cirrostratus.org:repos/looker.git $GIT_BRANCH:master
	;;
    ssh)
	ssh ubuntu@looker01.${ENV}.cirrostratus.org || ssh ubuntu@looker02.${ENV}.cirrostratus.org 
	;;
    put)
	shift
	if [ -z $1 ] ; then
	    echo "ERROR - no files to put"
	    givehelp
	    exit
	fi

	for i in 01 02
	do
	    if scp $* ubuntu@looker${i}.${ENV}.cirrostratus.org:/home/ubuntu
	    then
		break
	    fi
	done
	;;
    get)
	shift
	if [ -z $1 ] || [ -z $2 ] ; then
	    echo "ERROR - no files to get"
	    givehelp
	    exit
        fi

	for i in 01 02
	do
	    if scp ubuntu@looker${i}.${ENV}.cirrostratus.org:/home/ubuntu/"$1" "$2"
	    then
		break
	    fi
	done
	;;
    *)
	givehelp
	;;
esac
