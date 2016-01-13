#!/bin/bash -e

##
## Simple file for testing bash commands
## 

# Set the environment - common to all scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d ${DIR} ]]; then DIR=${PWD}; fi
. "$DIR/common.sh"

set -x

PACKAGE_NAME=bash

RESULT=0
dpkg -l ${PACKAGE_NAME} > /dev/null 2>&1 || RESULT=1
if [ $RESULT -eq 0 ]; then
    echo "bash is installed"
fi






