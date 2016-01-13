#!/bin/bash -e
# Script to clean up the installation

# Set the environment - common to all scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d ${DIR} ]]; then DIR=${PWD}; fi
. "$DIR/common.sh"

# set -x

# Uninstall the Debian file and other packages which were installed
# NOTE: if not installed then dpkg will return exit 1 - which will exit. The || RESULT=1 will 'catch' the error
RESULT=0
dpkg -l ${PACKAGE_NAME} > /dev/null 2>&1 || RESULT=1
if [ $RESULT -eq 0 ]; then
    dpkg -P ${PACKAGE_NAME}
fi

# TODO: check that proftpd was previously installed. Shouldn't be uninstalled
if [ -f /etc/init.d/proftpd ]; then
    dpkg -P proftpd-basic
fi

if [ -d ${BUILD_DIR} ]; then
    rm -rf ${BUILD_DIR}
fi

if [ -f ${DEB_FILE} ]; then
    rm ${DEB_FILE}
fi

# Remove the test user if it exists

ret=false
getent passwd ${TEST_USER} > /dev/null 2>&1 && ret=true
if $ret; then
    deluser ${TEST_USER}
    rm -rf ${S3MOUNT}/${TEST_USER}
fi

# Clean up test framework
if [ -e ./shunit ]; then
    rm -rf shunit
    rm -rf ${SHUNIT}
fi

# Remove the intermediate files
if [ -d /tmp/cats-ftp ]; then
    rm -rf /tmp/cats-ftp
fi
