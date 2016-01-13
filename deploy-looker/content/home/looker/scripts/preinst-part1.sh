#!/bin/bash
# this script is executed on the TARGET MACHINE
# blame: barry@productops.com jan 2016
# BOLT-1611 deploy a looker jar via Sagoku
# preinst.sh

# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

# SYSCTL --------- --------- --------- --------- --------- --------- ---------
SYSCTLOOKER=/etc/sysctl.d/87-looker.conf
if [ ! -f $SYSCTLOOKER ] ; then
echo >$SYSCTLOOKER <<EOF
net.ipv4.tcp_keepalive_time=200
net.ipv4.tcp_keepalive_intvl=200
net.ipv4.tcp_keepalive_probes=5
EOF
fi

sysctl --system

# user looker --------- --------- --------- --------- --------- --------- ---------
if ! grep looker /etc/group >/dev/null
then
sudo groupadd looker
fi

if ! grep looker /etc/passwd >/dev/null
sudo useradd -m -g looker looker
fi

# ulimits --------- --------- --------- --------- --------- --------- ---------
LIMITSCONF=/etc/security/limits.conf
if ! grep ^looker $LIMITSCONF >/dev/null
then
echo >>$LIMITSCONF <<EOF
looker     soft     nofile     4096
looker     hard     nofile     4096
EOF
fi