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

cd /home/looker/looker
# start up looker as the right user. ------------------------------------------
if [ $USER != looker ] ; then 
    sudo su - looker /home/looker/looker/looker $*
else
    /home/looker/looker/looker $*    
fi 
