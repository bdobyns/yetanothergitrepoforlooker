#!/bin/bash

### BEGIN INIT INFO
# Provides:          looker
# Required-Start:    ntp
# Required-Stop:     
# Should-Start:      
# Should-Stop:       
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

LOOKERBIN=/home/looker/looker 
if [ ! -d $LOOKERBIN ] ; then 
    exit 42
fi 

cd $LOOKERBIN
# start up looker as the right user. ------------------------------------------
if [ -z $USER ] || [ $USER != looker ] ; then 
    sudo su - looker $LOOKERBIN/looker $*
else
    $LOOKERBIN/looker $*    
fi 
