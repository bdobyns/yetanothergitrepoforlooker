#!/bin/bash -e 
# cats-1349 csp ftp upload server - cats-1393 this is the authorization script 
# blame: bdobyns@productops.com June 2015
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# make sure we have permission to do the work
if [ $UID -ne 0 ] ; then
    echo "[$$] $0 must be run as UID 0, $AUTHD_ACCOUNT not authorized" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.badUid:1|c'
    exit 1
    echo auth_ok:-1
    echo end
    echo " "
fi

# get common variables
if [ '-bash' == "$0" ] ; then
    FTPHOME=/etc/pure-ftpd/scripts
else
    FTPHOME=`dirname $0`
fi
source $FTPHOME/common.sh
ME=`basename $0`
TMP=/var/tmp

# cleanup old garbage from running authscript.sh
( cd $TMP ; find $TMP -name ${ME}'*' -type f -mtime +1 -delete )


# this is our home directory
# CSP_FTP_HOMES=/mnt/csp/ftp/users
if [ ! -d $CSP_FTP_HOMES ] ; then
    mkdir -p $CSP_FTP_HOMES
    # chmod 0755 /mnt/csp /mnt/csp/ftp /mnt/csp/ftp/users
fi

# pure-authd will call us with these environment variables set
#	AUTHD_ACCOUNT
#	AUTHD_PASSWORD
#	AUTHD_LOCAL_IP
#	AUTHD_LOCAL_PORT
#	AUTHD_REMOTE_IP
#	AUTHD_ENCRYPTED
# we must return with something like
#	auth_ok:1
#	uid:1043
#	gid:1043
#	dir:/home/foo
#	end

if [ -z $AUTHD_PASSWORD ] || [ -z $AUTHD_ACCOUNT ] ; then
    echo auth_ok:-1
    echo end
    echo " "
    if [ -z $AUTHD_ACCOUNT ] ; then 
        echo "[$$] AUTHD_ACCOUNT empty, no username" | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.NoUserName:1|c'
    fi
    if [ -z $AUTHD_PASSWORD ] ; then 
        echo "[$$] AUTHD_PASSWORD empty, no password" | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.NoPassword:1|c'
    fi
    echo auth_ok:-1
    echo end
    echo " "
    exit 1
else
    echo "[$$] user: $AUTHD_ACCOUNT   pass: $AUTHD_PASSWORD attempting login" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.Attempted:1|c'
fi

# curl against bolt-service to validate the password
BOLT_SERVICE="bolt-service.apps.$SGK_ENVIRONMENT.$SGK_BASE_DOMAIN"
BOLT_RESPONSE=$TMP/"${ME}"_"$$"_bolt_response_$AUTHD_ACCOUNT
BOLT_REQUEST=`echo $BOLT_RESPONSE | sed -e s/response/request/ `
# we call against BOLT for auth, because there's some weird pv in iac-aaa 
#    AccessGlobalAvailableFlag that forces everyone to auth true on iac-aaa/password/validate
# doing so (forcing all auth to win) makes the unit tests for auth to fail.
echo "curl --silent $BOLT_SERVICE/v3/auth/login --data 'user=$AUTHD_ACCOUNT' --data 'password=$AUTHD_PASSWORD'" >$BOLT_REQUEST
( echo -n "[$$] "; cat  $BOLT_REQUEST ) | logger -t csp_ftp_auth
curl --silent $BOLT_SERVICE/v3/auth/login --data "user=$AUTHD_ACCOUNT" --data "password=$AUTHD_PASSWORD" >$BOLT_RESPONSE
echo "[$$] $AUTHD_ACCOUNT have BOLT response" | logger -t csp_ftp_auth
# ( echo "[$$] "; cat "$BOLT_RESPONSE" | tr '\n' ' ' ) | logger -t csp_ftp_auth
# note that if we fail to auth, the BOLT_RESPONSE may be completely empty
if [ ! -s $BOLT_RESPONSE ] ; then # zero size
    echo "[$$] user '$AUTHD_ACCOUNT' not authorized - bad password or user name - empty bolt response" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.EmptyBoltResponse:1|c'
    echo auth_ok:-1
    echo end
    echo " "
    exit 1
fi
# get the rest of our data from the BOLT_RESPONSE
AUTHORIZED=`cat $BOLT_RESPONSE  | jq .auth`  # auth=true means we validated the password 
echo "[$$] $AUTHD_ACCOUNT AUTHORIZED='$AUTHORIZED'" | logger -t csp_ftp_auth
SESSIONID=`cat $BOLT_RESPONSE  | jq .id`     # we could save the session ID, but I don't know why we would
echo "[$$] $AUTHD_ACCOUNT SESSIONID='$SESSIONID'" | logger -t csp_ftp_auth
ACCOUNT_EID=`cat $BOLT_RESPONSE | jq '.authAccts[].eid' | tr -d '"' `  # authAccts.eid is the external uuid for the user account
echo "[$$] $AUTHD_ACCOUNT ACCOUNT_EID='$ACCOUNT_EID'" | logger -t csp_ftp_auth
ACCOUNT_TYP=`cat $BOLT_RESPONSE | jq '.authAccts[].type' | tr -d '"' | tr [a-z] [A-Z] `  # needed later when we write back
echo "[$$] $AUTHD_ACCOUNT ACCOUNT_TYP='$ACCOUNT_TYP'" | logger -t csp_ftp_auth
HAS_ROLE=`cat $BOLT_RESPONSE | jq '.authAccts[].roles' | grep -i $CSP_FTP_REQUIRED_ROLE | tr -d '" ' `  # only publishers log in
echo "[$$] $AUTHD_ACCOUNT HAS_ROLE='$HAS_ROLE'" | logger -t csp_ftp_auth
USER_NAME=`cat $BOLT_RESPONSE | jq '.authAccts[].creds[].value' | tr -d '"' `  # just want to double check
echo "[$$] $AUTHD_ACCOUNT USER_NAME='$USER_NAME'" | logger -t csp_ftp_auth

if [ -z $AUTHORIZED ] || [ -z $ACCOUNT_EID ] || [ -z $ACCOUNT_TYP ] || [ $AUTHORIZED != "true" ] || [ "$USER_NAME" != "$AUTHD_ACCOUNT" ] || [ -z $HAS_ROLE ] ; then
    if [ -z $AUTHORIZED ] || [ $AUTHORIZED != "true" ] ; then
	echo "[$$] $AUTHD_ACCOUNT not authorized - bad password or user name" | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.BadPasswordOrUserName:1|c'
    elif [ -z $ACCOUNT_EID ] ; then
        echo "[$$] no account EID for $AUTHD_ACCOUNT - not authorized" | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.NoAccountEID:1|c'
    elif [ -z $ACCOUNT_TYP ] ; then
        echo "[$$] no account type for $AUTHD_ACCOUNT - not authorized" | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.NoAccountType:1|c'
    elif [ "$USER_NAME" != "$AUTHD_ACCOUNT" ] ; then
       echo "[$$] the account username $USER_NAME does not match $AUTHD_ACCOUNT - not authorized" | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.NoUserNameMatch:1|c'
    elif [ -z $HAS_ROLE ] ; then
       echo "[$$] the account username $USER_NAME is not a $CSP_FTP_REQUIRED_ROLE - not authorized" | logger -t csp_ftp_auth
       $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.Not'$CSP_FTP_REQUIRED_ROLE'Role:1|c'
    fi
    # -1 means fail hard, and don't try any other auth methods 
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.fail.user.'$AUTHD_ACCOUNT':1|c'
    echo auth_ok:-1
    echo end
    echo " " 
    exit 1
fi

# we get the prefs if any from our best friend IAC
IAC_RESPONSE=$TMP/"${ME}"_"$$"_iac_response_$AUTHD_ACCOUNT
IAC_SERVICE="iac-service.apps.$SGK_ENVIRONMENT.$SGK_BASE_DOMAIN"
# it's more efficient to get the EID from the bolt call, since /search/byUsername takes 5+ seconds
# ACCOUNT_EID=`curl --silent "$IAC_SERVICE/search/byUsername?username=$AUTHD_ACCOUNT" | jq '.results[].id' | tr -d '"'  `
UID_KEY=.preferences.CspFtpUid
GID_KEY=.preferences.CspFtpGid
echo "[$$] "curl --silent "$IAC_SERVICE/account/$ACCOUNT_EID" | logger -t csp_ftp_auth
curl --silent "$IAC_SERVICE/account/$ACCOUNT_EID" >$IAC_RESPONSE
echo "[$$] $AUTHD_ACCOUNT have IAC response" | logger -t csp_ftp_auth
# don't try to JQ out the prefs if they don't exist, or the -e will kill the whole script
if cat $IAC_RESPONSE | grep CspFtpUid >/dev/null 
then
    IAC_UID=`cat $IAC_RESPONSE | jq $UID_KEY | tr -d '"' | grep -v null`
    echo "[$$] $AUTHD_ACCOUNT IAC_UID='$IAC_UID'" | logger -t csp_ftp_auth
    IAC_GID=`cat $IAC_RESPONSE | jq $GID_KEY | tr -d '"' | grep -v null`
    echo "[$$] $AUTHD_ACCOUNT IAC_GID='$IAC_GID'" | logger -t csp_ftp_auth
fi
LOCAL_UID=`grep "^$AUTHD_ACCOUNT"':' /etc/passwd | cut -d : -f 3`
echo "[$$] $AUTHD_ACCOUNT LOCAL_UID='$LOCAL_UID'" | logger -t csp_ftp_auth

#
# FIVE CASES TO CONSIDER:
#
# 1) no prefs in IAC and not a local user 
#    make local
#    write UID to IAC
# 2) no prefs in IAC and local user exists
#    write UID to IAC
# 3) prefs in IAC and not a local user
#    make local with UID
# 4) prefs in IAC and local user exists and UID matches
#    use
# 5) prefs in IAC and local user exists and UID does not match
#    update IAC

function write_prefs_to_iac() {
    if [ -z $1 ] || [ -z $2] ; then
	echo "[$$] cannot write IAC_UID='$IAC_UID' or IAC_GID='$IAC_GID' because one or both are empty" | logger -t csp_ftp_auth
	return
    elif [ -z $ACCOUNT_EID ] ; then
	echo "[$$] cannot write IAC prefs because ACCOUNT_EID='$ACCOUNT_EID' empty" | logger -t csp_ftp_auth
	return
    elif [ -z $ACCOUNT_TYP ] ; then
	echo "[$$] cannot write IAC prefs because ACCOUNT_TYP='$ACCOUNT_TYP' empty" | logger -t csp_ftp_auth
	return
    fi
    # post back the UID and GID
    # if someone freaks over storing this in the IAC dataase, maybe we can put it the IID service instead
    IAC_PREFS_RESPONSE=$TMP/"${ME}"_"$$"_iac_prefs_response
    JSON='{"type":"'$ACCOUNT_TYP'","id":"'$ACCOUNT_EID'","preferences":{"CspFtpUid":"'$1'","CspFtpGid":"'$2'"}}'
    CT="Content-Type: application/json"
    curl --silent "$IAC_SERVICE/account/$ACCOUNT_EID" -H "$CT" --data "$JSON"  >$IAC_PREFS_RESPONSE
    # logging
    echo "[$$] wroteIAC $JSON" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.logic.auth.wroteIac:1|c'
}

if [ -z $IAC_UID ] && [ -z $LOCAL_UID ]; then
    echo "[$$] case1 $AUTHD_ACCOUNT not in IAC and not a local user" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase1.NotInIacAndNotLocalUser:1|c'
    # we need to create a new uid for this user and save it back to IAC
    # normally $RANDOM returns 0-32767 but the range of UID is 0-65534
    # this hack gives us a bigger hash space (60000 buckets) to try and shove the few hundred users into.
    IAC_UID=$[ $RANDOM$RANDOM % 60000 + 5530 ]
    IAC_GID=$IAC_UID
    # create the user
    groupadd --gid "$IAC_GID" "$AUTHD_ACCOUNT" 2>&1 | logger -t csp_ftp_auth
    useradd --base-dir "$CSP_FTP_HOMES" --create-home --uid "$IAC_UID" --gid "$IAC_GID" --comment "$ACCOUNT_EID"  "$AUTHD_ACCOUNT" 2>&1 | logger -t csp_ftp_auth
    LOCAL_UID=$IAC_UID
    LOCAL_GID=$IAC_UID
    # write to IAC
    write_prefs_to_iac $IAC_UID $IAC_UID

elif [  -z $IAC_UID ] && [  ! -z $LOCAL_UID ]; then
    echo "[$$] case2 $AUTHD_ACCOUNT not in IAC and local user exists with uid=$LOCAL_UID" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase2.NotInIacAndLocalUserExists:1|c'
    IAC_UID=$LOCAL_UID
    IAC_GID=$LOCAL_GID
    # write UID to IAC
    write_prefs_to_iac $IAC_UID $IAC_UID

elif [  ! -z $IAC_UID ] && [  -z $LOCAL_UID ]; then
    echo "[$$] case3 $AUTHD_ACCOUNT in IAC with uid=$IAC_UID and not a local user" | logger -t csp_ftp_auth 
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase3.InIacWithUidAndNotLocal:1|c'
    # make local group with GID
    groupadd --gid "$IAC_GID" "$AUTHD_ACCOUNT" 2>&1 | logger -t csp_ftp_auth
    # IAC had a UID but no local user, create one with the right uid
    useradd --base-dir "$CSP_FTP_HOMES" --create-home --uid "$IAC_UID" --gid "$IAC_GID" --comment "$ACCOUNT_EID"  "$AUTHD_ACCOUNT" 2>&1 | logger -t csp_ftp_auth

elif [ ! -z "$LOCAL_UID" ] && [ ! -z "$IAC_UID" ] && [ "$IAC_UID" == "$LOCAL_UID" ] ; then
    echo "[$$] case4 $AUTHD_ACCOUNT in IAC with uid=$IAC_UID and local user with uid=$LOCAL_UID exists and UID matches" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase4.InIacAndLocalUidMatches:1|c'
    # silently win

elif  [ ! -z "$LOCAL_UID" ] && [ ! -z "$IAC_UID" ] &&[ "$IAC_UID" != "$LOCAL_UID" ] ; then
    echo "[$$] case5  $AUTHD_ACCOUNT in IAC with uid=$IAC_UID and local user with uid=$LOCAL_UID exists and UID does not match" | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase5.InIacAndLocalUidDoesNotMatch:1|c'
    # update IAC

    # the local UID of the user $LOCAL_UID and the IAC returned UID $IAC_UID do not match
    LOCAL_EID=`grep "^$AUTHD_ACCOUNT" /etc/passwd | cut -d : -f 5 `
    if [ "$LOCAL_EID" != "$ACCOUNT_EID" ] ; then
        echo "[$$] case5.1  $AUTHD_ACCOUNT IAC eid='$ACCOUNT_EID' does not match local eid='$LOCAL_EID'  " | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase51.EidDoesNotMatch:1|c'
        # fail if the EID don't match
        echo auth_ok:-1
	echo end
        echo " "
	echo "[$$] $AUTHD_ACCOUNT's local eid of the user '$LOCAL_EID' and the IAC returned EID '$ACCOUNT_EID' do not match"
	exit 1
    else
        echo "[$$] case5.2 $AUTHD_ACCOUNT eid=$ACCOUNT_EID matches, update IAC with uid=$LOCAL_UID " | logger -t csp_ftp_auth
	$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase52.EidMatchesUpdateIacWithUid:1|c'
        # otherwise pretend that the local UID is authoritative
        IAC_UID=$LOCAL_UID
	IAC_GID=$LOCAL_UID
	write_prefs_to_iac $IAC_UID $IAC_UID
    fi

else
    echo "[$$] case6 $AUTHD_ACCOUNT there should be no cases not handled by the if statements above - unreachable code " | logger -t csp_ftp_auth
    $FTPHOME/statsd-client.sh 'csp-ftp-service.auth.logic.AuthCase6.Unreachable:1|c'
    # but we include an else clause for completeness
    echo auth_ok:-1
    echo end
    echo " "
    echo "[$$] this should be unreachable and/or call pager duty"
    exit 1
fi

# make sure all the directories down to the authd_account are navigable
DER=
for FRAG in `echo $CSP_FTP_HOMES/$AUTHD_ACCOUNT | tr / ' ' `
do
    DER=$DER/$FRAG
    chmod 755 $DER
done

# make the directories that need to exist per @SamWotring's comment of Apr-13-2015 in CATS-1349
# amended to conform to the directory names users are used to/have had. 2015-09-01 17:51:50, nkerr, CEDAR-3509
for DER in PAGE_IMAGES LITM_ZIPS
do
    mkdir -p $CSP_FTP_HOMES/$AUTHD_ACCOUNT/$DER
    chown -R $AUTHD_ACCOUNT $CSP_FTP_HOMES/$AUTHD_ACCOUNT
    chgrp -R $AUTHD_ACCOUNT $CSP_FTP_HOMES/$AUTHD_ACCOUNT
    chmod 755 $CSP_FTP_HOMES/$AUTHD_ACCOUNT/$DER
done

# finally succeed
echo "[$$] $AUTHD_ACCOUNT authorized in directory $CSP_FTP_HOMES/$AUTHD_ACCOUNT" | logger -t csp_ftp_auth
$FTPHOME/statsd-client.sh 'csp-ftp-service.auth.authorized.user.'$AUTHD_ACCOUNT':1|c'

echo auth_ok:1
echo uid:"$IAC_UID"
echo gid:"$IAC_GID"
# the /./ syntax takes advantage of the virtual chroot feature of pure-ftpd
echo dir:"$CSP_FTP_HOMES/$AUTHD_ACCOUNT"
echo end

# all done
exit 0
