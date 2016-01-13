#!/bin/sh

cd $HOME/looker 
# set your java memory- there should be over 1.5G of system memory 
# left to run the OS
MEM=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
JM=`expr $MEM - 1500000`
JAVAMEM="${JM}k"

# Extra Java startup args and Looker startup args.  These can also be set in
# a file named lookerstart.cfg
JMXARGS="-Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote -Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote.port=9910 -Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote.ssl=false -Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote.local.only=false -Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote.authenticate=true -Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote.access.file=${HOME}/.lookerjmx/jmxremote.access -Dcom.sun.akuma.jvmarg.com.sun.management.jmxremote.password.file=${HOME}/.lookerjmx/jmxremote.password"

# to set up JMX monitoring, add JMXARGS ot JAVAARGS
JAVAARGS=""
LOOKERARGS=""

# check for a lookerstart.cfg file to set JAVAARGS and LOOKERARGS
if [ -r ./lookerstart.cfg ]; then
  . ./lookerstart.cfg
fi

start() {
    if [ -e .deploying ]; then
        echo "Startup suppressed: ${PWD}/.deploying file exists.  Remove .deploying file to allow startup"
        exit 1
    fi

    LOCKFILE=.starting
    if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
        echo "Startup suppressed: ${LOCKFILE} contains running pid, startup script is already running"
        exit 1
    fi
    
    # make sure the lockfile is removed when we exit and then claim it
    trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
    echo $$ > ${LOCKFILE}

    fixcrypt
    java \
  -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC \
  -XX:MaxPermSize=128M \
  -Xms$JAVAMEM -Xmx$JAVAMEM \
  -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps \
  -Xloggc:/tmp/gc.log  ${JAVAARGS} \
  -jar looker.jar start ${LOOKERARGS}

    if [ -x ./tunnel ]; then
       ./tunnel start
    fi

    rm -f ${LOCKFILE}
}

stop() {
    pid=`cat .tmp/looker.pid`
    if [ -f .status_server_token ] && [ -x /usr/bin/curl ]; then
        state="running"
        token=`cat .status_server_token`
        request="control/stop?token=${token}"
        timeout 20 curl -m 10 -ks https://127.0.0.1:9999/${request} > /dev/null 2>&1
        ECODE=$?
        [ $ECODE -eq 7 ] && state="stopped"
        if [ $ECODE -gt 7 ] ; then
            kill $pid
        fi
        for i in {1..30}; do
            timeout 20 curl -m 5 -ks https://127.0.0.1:9999/alive > /dev/null 2>&1
            ECODE=$?
            if [ $ECODE -eq 7 ]; then
              state="stopped"
              break
            fi
            if [ $ECODE -gt 7 ] ; then
                kill -9 $pid
            fi
            sleep 1
        done
        if [ "${state}" = "running" ]; then
            echo "Force Stop Looker Web Application"
            kill $pid
            kill -0 $pid && kill -9 $pid
        fi
    else
        timeout 20 java -jar looker.jar stop
        if [ $? -ne 0 ]; then
            kill -9 $pid
        fi
    fi
}

fixcrypt() {
    CRYPTEXIST=`/sbin/ldconfig -p | grep -c '\slibcrypt.so\s'`

    if [ $CRYPTEXIST -eq 0 ]; then
        if [ ! -d .tmp ]; then
            mkdir .tmp
        fi
        CRYPTLN=`/sbin/ldconfig -p | grep '\slibcrypt\.so\.[[:digit:]]' | awk '{print $(NF)}'`
        ln -s -f $CRYPTLN `pwd`/.tmp/libcrypt.so
        export LD_LIBRARY_PATH=`pwd`/.tmp/:$LD_LIBRARY_PATH
    fi
}

case "$1" in
  start)
    start
	;;
  stop)
    stop
	;;
  restart)
	echo "Restarting Looker Web Application" "looker"
        stop
        sleep 3
        start
	;;
  status)
        curl -ks https://127.0.0.1:9999/alive > /dev/null 2>&1
        if [ $? -eq 7 ]; then
          echo "Status:Looker Web Application stopped"
          exit 7
        else
          echo "Status:Looker Web Application running"
          exit 0
        fi
        ;;
  *)
        java -jar looker.jar $*
        ;;
esac

exit 0

