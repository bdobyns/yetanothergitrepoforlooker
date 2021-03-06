#!/bin/bash 
# this script is executed on the TARGET MACHINE before the deb package is unpacked
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# preinst.sh

# summary of how this script can be called:
#        * <new-preinst> `install'
#        * <new-preinst> `install' <old-version>
#        * <new-preinst> `upgrade' <old-version>
#        * <old-preinst> `abort-upgrade' <new-version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

case "$1" in
    install|upgrade)
    ;;

    abort-upgrade)
    ;;

    *)
        echo "preinst called with unknown argument \`$1'" >&2
        exit 1
    ;;
esac

# JAVA   --------- --------- --------- --------- --------- --------- ---------
WHICHJAVA=`update-java-alternatives -l`
JAVABIN=`which java`
if [ -z "$WHICHJAVA" ] || [ -z "$JAVABIN" ] ; then
    echo "NO JAVA AVAILABLE"
    exit 42
fi

# SYSCTL --------- --------- --------- --------- --------- --------- ---------
SYSCTL=/etc/sysctl.d/87-looker.conf
if  [ ! -f $SYSCTL ] || ! grep looker $SYSCTL >/dev/null ; then
cat >$SYSCTL <<EOF
# created by the ithaka looker installer
# $0
net.ipv4.tcp_keepalive_time = 200
net.ipv4.tcp_keepalive_intvl = 200
net.ipv4.tcp_keepalive_probes = 5
EOF
fi

sysctl --system

# user looker --------- --------- --------- --------- --------- --------- ---------
if ! grep looker /etc/group >/dev/null
then
sudo groupadd looker
fi

if ! grep looker /etc/passwd >/dev/null
then
sudo useradd -m -s /bin/bash -g looker looker
fi

# ulimits --------- --------- --------- --------- --------- --------- ---------
LIMITSCONF=/etc/security/limits.conf
if ! grep ^looker $LIMITSCONF >/dev/null
then
cat >>$LIMITSCONF <<EOF

# created by the ithaka looker installer
# $0
looker     soft     nofile     4096
looker     hard     nofile     4096
EOF
fi

exit 0