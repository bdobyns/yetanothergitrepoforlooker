#!/bin/bash

# setup for looker on a naked new box
# see http://www.looker.com/docs/setup-and-management/on-prem-install/installation

echo <<EOF
net.ipv4.tcp_keepalive_time=200
net.ipv4.tcp_keepalive_intvl=200
net.ipv4.tcp_keepalive_probes=5
EOF