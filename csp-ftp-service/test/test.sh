#!/bin/bash

##
## Script to test the debian installation from setup, package and dpkg. 
## Uses the shUnit2 bash testing framework: https://code.google.com/p/shunit2/
##
## Use 'set -x' to enable debugging from a point and then use 'set +x' to disable it
## WARN: Do not use 'set -e' when starting the shell or assertTrue will always fail
##

# set -x

# Set the environment - common to all scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d ${DIR} ]]; then DIR=${PWD}; fi
. "$DIR/common.sh"

# Test to ensure that the cats package is installed
testCatsFtp() {
    dpkg -l cats-ftp-service > /dev/null 2>&1
    assertTrue "Not installed" $?
}

# Check to ensure that proftpd is installed; this will return exit 3 if it's not running
testProftp() {
    STATUS=$(/usr/sbin/service proftpd status)
    assertEquals "ProFTPD started" "ProFTPD is started in standalone mode, currently running." "${STATUS}"
}

# Tests to ensure that the TEST_USER has been added to the system
testTestUser() {
    ret=false
    getent passwd ${TEST_USER} > /dev/null 2>&1 && ret=true
    assertTrue "User: ${TEST_USER} doesn't exist" $ret
}

# Checks to see that the S3 mount exists
testS3Fuse() {
    assertTrue "[ -d ${S3MOUNT} ]"
}

# Load unit test framework and execute tests
. ./shunit/src/shunit2



