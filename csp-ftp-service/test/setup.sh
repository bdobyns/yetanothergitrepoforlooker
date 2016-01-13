#!/bin/bash -e
set -x
# Wrapper script which will create a Debian binary from a package file.

# Set the environment - common to all scripts
DIR="${BASH_SOURCE%/*}"
if [[ ! -d ${DIR} ]]; then DIR=${PWD}; fi
. "$DIR/common.sh"

# Simulate the test environment

mkdir -p ${BUILD_DIR}

# Create a test user
useradd ${TEST_USER} -s /bin/bash -b ${S3MOUNT} -m
chpasswd << EOF
${TEST_USER}:ftp
EOF

# TODO: should check to see if packages are installed by this scripi and only remove
# them if they are.

RESULT=0
dpkg -s debconf > /dev/null 2>&1 || RESULT=1
if [ $RESULT -eq 0 ]; then
    apt-get install debconf
fi

# Install the proftpd package and any control file dependencies
# In a production sugoku environment this will be installed by it's own process
if [ ! -f /etc/init.d/proftpd ]; then
    # we install from a deb because it's non-interactive - unlike apt-get which requires a selection
    debconf-set-selections <<< "proftpd-basic     shared/proftpd/inetd_or_standalone     select     standalone"
    apt-get install proftpd-basic
#    dpkg --install lib/proftpd-basic*.deb
fi

# Create the debian package scripts

../build/package.sh ${SRC_DIR} ${BUILD_DIR} ${PACKAGE_NAME} ${VERSION}

# Create the debian package. This will create a *.deb file in /mnt/deb-builds
dpkg-deb --build ${BUILD_DIR}

# Install the package
dpkg -i ${DEB_FILE}


