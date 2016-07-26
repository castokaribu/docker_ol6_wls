#!/bin/sh
# 
####  Based on  http://ruleoftech.com/2013/weblogic-server-auto-restart-with-node-manager-as-linux-service
#
# wlsbased Oracle Weblogic Base Domain service
#
# chkconfig:   345 85 15
# description: Oracle Weblogic Base Domain service

### BEGIN INIT INFO
# Provides: wlsbased
# Required-Start: $network $local_fs
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6
# Short-Description: Oracle Weblogic Base Domain service.
# Description: Starts and stops Oracle Weblogic Base Domain.
### END INIT INFO

#. /etc/rc.d/init.d/functions

# Your WLS home directory (where wlserver_10.3 is)
export MW_HOME="/u01/app/oracle/middleware"
export DOMAIN_NAME="base_domain"
export SERVER_NAME="AdminServer"
export DOMAIN_HOME="$MW_HOME/user_projects/domains/$DOMAIN_NAME"
export JAVA_HOME="/usr/lib/jvm/jrockit-jdk1.6.0_45-R28.2.7-4.1.0"
#DAEMON_USER="root"
#PROCESS_STRING="^.*/u01/app/oracle/middleware/.*weblogic.NodeManager.*"
PROCESS_STRING=".*weblogic.Name=AdminServer*.*$MW_HOME.*"

#source $MW_HOME/wlserver_10.3/server/bin/setWLSEnv.sh > /dev/null
#export NodeManagerHome="$WL_HOME/common/nodemanager"
SERVER_LOCK_FILE="$DOMAIN_HOME/servers/$SERVER_NAME/tmp/$SERVER_NAME.lok"

PROGRAM_START="$DOMAIN_HOME/bin/startWebLogic.sh"
PROGRAM_STOP="$DOMAIN_HOME/bin/stopWebLogic.sh"
SERVICE_NAME=`/bin/basename $0`
SERVICE_DESC="Oracle Weblogic Base Domain"
LOCKFILE="/var/lock/subsys/$SERVICE_NAME"

RETVAL=0

start() {
        OLDPID=`/usr/bin/pgrep -f $PROCESS_STRING`
        if [ ! -z "$OLDPID" ]; then
            echo "$SERVICE_NAME is already running (pid $OLDPID) !"
            exit
        fi

        echo -n $"Starting $SERVICE_NAME ($SERVICE_DESC): "
        /bin/su $DAEMON_USER -c "$PROGRAM_START"

        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && touch $LOCKFILE
}

stop() {
        echo -n $"Stopping $SERVICE_NAME ($SERVICE_DESC): "
        /bin/su $DAEMON_USER -c "$PROGRAM_STOP"
        OLDPID=`/usr/bin/pgrep -f $PROCESS_STRING`
        if [ "$OLDPID" != "" ]; then
            /bin/kill -TERM $OLDPID
        else
            /bin/echo "$SERVICE_NAME is stopped"
        fi
        echo
        /bin/rm -f $SERVER_LOCK_FILE
        [ $RETVAL -eq 0 ] && rm -f $LOCKFILE

}

restart() {
        stop
        sleep 10
        start
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart|force-reload|reload)
        restart
        ;;
  condrestart|try-restart)
        [ -f $LOCKFILE ] && restart
        ;;
  status)
        OLDPID=`/usr/bin/pgrep -f $PROCESS_STRING`
        if [ "$OLDPID" != "" ]; then
            /bin/echo "$SERVICE_NAME is running (pid: $OLDPID)"
        else
            /bin/echo "$SERVICE_NAME is stopped"
        fi
        RETVAL=$?
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
        exit 1
esac

exit $RETVAL

