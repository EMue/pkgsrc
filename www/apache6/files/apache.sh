#! /bin/sh
#
# $NetBSD: apache.sh,v 1.6 2001/02/07 15:11:18 tron Exp $
#
# PROVIDE: apache
# REQUIRE: DAEMON

name="apache"
ctl_command="@PREFIX@/sbin/apachectl"
command="@PREFIX@/sbin/httpd"
pidfile="/var/run/httpd.pid"
conffile="@PREFIX@/etc/httpd/httpd.conf"

apache_start="start"

if [ -f @PREFIX@/etc/httpd/apache_start.conf ]
then
	# This file can reset apache_start to "startssl"
	. @PREFIX@/etc/httpd/apache_start.conf
fi

cmd=${1:-start}

if [ -x ${ctl_command} -a -x ${command} ]
then
	case ${cmd} in
	start)
		echo "Starting ${name}."
		${ctl_command} ${apache_start} > /dev/null
		;;

	stop)
		if [ -f ${pidfile} ]
		then
			echo "Stopping ${name}."
			${ctl_command} ${cmd} > /dev/null
		fi
		;;

	restart)
		( $0 stop )
		sleep 5
		$0 start
		;;

	status)
		${ctl_command} ${cmd}
		;;

	*)
		echo 1>&2 "Usage: $0 [restart|start|stop|status]"
		exit 1
		;;
	esac
fi
exit 0
