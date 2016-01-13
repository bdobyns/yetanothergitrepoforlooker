#!/bin/bash
# provenance: originally written for the CATS-1349 csp-ftp-service
# blame: bdobyns@productops.com June 2015
 
# PERSISTENT-VARAIBLE-SETTERS ============================================================

function set_watchable() {
# $1 = name
# $2 = default_value
# $3 = wtype (persistentvariable, statuslight, dipswitch)
# $4 = vtype (string, int, datetime ...)
    WNAME="$1"
    WVALUE="$2"
    if [ -z "$3" ] ; then WTYPE=persistentvariable
    else WTYPE=`echo $3 | tr A-Z a-z`  ; fi
    if [ -z "$4" ] ; then VTYPE=string 
    else VTYPE="$4" ; fi

    case "$WTYPE" in 
	persistentvariable)
	    LTYPE=PersistentVariable
	    ;;
	dipswitch)
	    LTYPE=DipSwitch
	    ;;
	statuslight)
	    LTYPE=StatusLight
	    ;;
	*)
	    exit 1 
	    ;;
    esac
    if [ -z "$WNAME" ] || [ -z "$WVALUE" ] || [ -z "$WTYPE" ] || [ -z "$VTYPE" ] || [ -z "$LTYPE" ] ; then exit 0 ; fi

    # create the $WNAME if it doesn't exist
    curl --silent http://localhost:8080/local/"$LTYPE"/"$WNAME"'?vType='"$VTYPE"'&defaultValue='"$WVALUE" >/dev/null
    # now write the desired current value, returns simply 'OK'
    CT='Content-Type: application/json'
    curl --silent http://localhost:8080/watchable/"$WTYPE"/"$WNAME" -X PUT -H "$CT" -d '{"value":"'"$WVALUE"'"}' >/dev/null
    # now read back the current value, which should be the one we wrote
    curl --silent http://localhost:8080/watchable/"$WTYPE"/"$WNAME" | jq .value | tr -d '"'
}

# $1 = name
# $2 = default_value
# $3 = vtype (string, int, datetime ...)
function set_persistentvariable() {
    set_watchable "$1" "$2" persistentvariable "$3"
}

# PERSISTENT-VARAIBLE-GETTERS ============================================================

# this will forcibly create the watchable if it does not exist, applying the default value
function watchable() {
# $1 = name
# $2 = default_value
# $3 = wtype (persistentvariable, statuslight, dipswitch)
# $4 = vtype (string, int, datetime ...)
    WNAME=$1
    WVALUE="$2"
    if [ -z "$3" ] ; then WTYPE=persistentvariable
    else WTYPE=`echo $3 | tr A-Z a-z`  ; fi
    if [ -z "$4" ] ; then VTYPE=string 
    else VTYPE="$4" ; fi

    case "$WTYPE" in 
	persistentvariable)
	    LTYPE=PersistentVariable
	    ;;
	dipswitch)
	    LTYPE=DipSwitch
	    ;;
	statuslight)
	    LTYPE=StatusLight
	    ;;
	*)
	    exit 1 
	    ;;
    esac
    if [ -z "$WNAME" ] || [ -z "$WVALUE" ] || [ -z "$WTYPE" ] || [ -z "$VTYPE" ] || [ -z "$LTYPE" ] ; then exit 0 ; fi

    # create the $WNAME if it doesn't exist
    curl --silent http://localhost:8080/local/"$LTYPE"/"$WNAME"'?vType='"$VTYPE"'&defaultValue='"$WVALUE" | jq .value | tr -d '"'
}
	
# $1 = name
# $2 = default_value
# $3 = vtype (string, int, datetime ...)
function persistentvariable () {
    watchable "$1" "$2" persistentvariable "$3"
}

# SAFE-PERSISTENT-VARAIBLE-GETTERS ============================================================

# this can return empty if the watchable doesn't exist yet.
# this returns the value in the watchable if it does exist.
function test_watchable() {
# $1 = name
# $2 = wtype (persistentvariable, statuslight, dipswitch)
    WNAME="$1"
    if [ -z "$2" ] ; then WTYPE=persistentvariable
    else WTYPE=`echo $2 | tr A-Z a-z`  ; fi

    # now read the current value, which might be empty if the watchable does not exist
    curl --silent http://localhost:8080/watchable/"$WTYPE"/"$WNAME" | jq .value | tr -d '"'
}

# $1 = name
function test_persistentvariable() {
    test_watchable "$1" persistentvariable
}

