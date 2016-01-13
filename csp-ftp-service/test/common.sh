## Common variables and functions for setup, test and teardown

# Set variables 
SRC_DIR="$(git rev-parse --show-toplevel)"  # top level of the git repo
VERSION=201502.11-19-48-21-138361295
PACKAGE_NAME=cats-ftp-service
BUILD_DIR=/mnt/deb-builds/${PACKAGE_NAME}-${VERSION}
DEB_FILE=${BUILD_DIR}.deb

# Related to the testing framework
SHUNIT=shunit2-2.1.6        # shUnit test framework
TEST_USER=ftptest
S3MOUNT=/tmp/test
TMP_DIR=/tmp/cats-ftp

if [ ! -e ./shunit ]; then
    echo "shunit dir doesn't exist; create it"
    tar xvfz ${SHUNIT}.tgz
    ln -s ${SHUNIT} shunit
fi

