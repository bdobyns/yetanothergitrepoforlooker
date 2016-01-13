#!/bin/bash -e
# this script is executed on the sagoku build machine
# blame: barry@productops.com jan 2016
# BOLT-1611 deply a looker jar via Sagoku
#   - Sagoku Deployable
set -x

export SRC_DIR=$1 #  root folder of the workspace, /opt/git/$reponame
export BUILD_DIR=$2 # /mnt/deb-builds/${PACKAGE_NAME}-${VERSION}
export PACKAGE_NAME=$3 # appName
export VERSION=$4 # autogenerated timestamp
echo "Using package $PACKAGE_NAME and version ${VERSION}"

HOMELOOKER=/home/looker
CONTENT=$SRC_DIR/deploy-looker/content

# the built debian is downloaded into the target in
#     /opt/download/${DEPLOYMENT_ID}.deb
#
# the built debian is arranged to be run (by sagoku) as
#     apt-get install -y --force-yes $PACKAGE_NAME
#
# or maybe (if there's no dependencies that need to be resolved) this can work
#     dpkg -i /opt/download/${DEPLOYMENT_ID}.deb
#
# so you can do this to try and re-install
#    sudo cp /opt/download/${DEPLOYMENT_ID}.deb  /var/cache/apt/archives/${PACKAGE_NAME}_0.0.0_all.deb
#    sudo apt-get install $PACKAGE_NAME
# which will let you see better error messages from apt-get

# copy package contents to build directory
cp -pr $CONTENT/* ${BUILD_DIR}/
# chown -R ubuntu:ubuntu ${BUILD_DIR}$HOMELOOKER
find ${BUILD_DIR}/home/looker -type f -exec chmod 644 "{}" ";"
find ${BUILD_DIR}/home/looker -type d -exec chmod 755 "{}" ";"
echo "${VERSION}" > ${BUILD_DIR}/version_num

# copy the watchable sidecar
aws s3 cp s3://sequoia-install/watchable-sidecar.jar ${BUILD_DIR}$HOMELOOKER/scripts/watchable-sidecar.jar
(
cd ${BUILD_DIR}$HOMELOOKER/scripts
echo 'server.port = 8080' >application.properties
zip watchable-sidecar.jar application.properties
)

# creating the main control file for this package
# according to the http://www.looker.com/docs/setup-and-management/on-prem-install/installation
#     we need libssl which is provided by libssl-dev 
#     and libcrypt which is provided by libc6
#     and ntpd for time synchronization
cat << EOF > ${BUILD_DIR}/DEBIAN/control
Package: $PACKAGE_NAME
Version: $VERSION
Maintainer: Ithaka Sequoia barry@productops.com
Architecture: all
Section: main
Priority: extra
Depends: libc6, libssl-dev, ntp
Replaces: 
Description: BOLT-1611 deploy a looker.jar via sagoku
   - Sagoku Deployable
   - pv support for config
EOF

# *creating* the post-install script for this package - executed in sagoku
# the post-install script is executed in the deployed instance
cat << END > ${BUILD_DIR}/DEBIAN/postinst
#!/bin/bash
echo $PACKAGE_NAME "Can do some post-install actions by this script" > /tmp/post-install-${PACKAGE_NAME}.log
bash -x $HOMELOOKER/scripts/postinst-part1.sh 2>&1 >> /tmp/post-install-${PACKAGE_NAME}.log
END
chmod 0755 ${BUILD_DIR}/DEBIAN/postinst


# creating the pre-install script for this package
# the pre-install script is executed in the deployed instance
cat << EOF > ${BUILD_DIR}/DEBIAN/preinst
#!/bin/bash
echo $PACKAGE_NAME "Can do some pre-install actions by this script" > /tmp/pre-install-${PACKAGE_NAME}.log
bash -x $HOMELOOKER/scripts/preinst-part1.sh 2>&1 >> /tmp/pre-install-${PACKAGE_NAME}.log
EOF
chmod 0755 ${BUILD_DIR}/DEBIAN/preinst

# there's a weird sagoku build error, trying to clean it up
cd /tmp
echo "$0 done"
exit 0

