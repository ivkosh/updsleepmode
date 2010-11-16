#!/bin/sh

PATH=/usr/bin:/bin:/usr/sbin

MIN_BATTERY_LEVEL=15
WRITE_LOG=

if [ "$1" != "-silent" ] ; then VERBOSE=1; fi

CURR_HIBERNATEMODE=`pmset -a -g|grep hibernatemode|awk '{print $2}'`
BATTERY_PERCENT=`ioreg -l | grep Capacity | tr '\n' ' | ' | awk '{printf("%d", $10/$5 * 100)}'`

if [ $UID == 0 ]; then
	PMSET='pmset'
else
	PMSET='sudo pmset'
fi

notify()
{
	if [ $VERBOSE ]; then 
		echo $@
	fi
}

log()
{
	if [ $WRITE_LOG ]; then
		logger -t updsleepmode $@
	fi
}

#log "Started with uid=${UID}"
notify "Battery level is \033[1m${BATTERY_PERCENT}%\033[0m"
log "Battery level is ${BATTERY_PERCENT}%"

if [ $BATTERY_PERCENT -gt $MIN_BATTERY_LEVEL ] ; then
	if [ $CURR_HIBERNATEMODE != 0 ] ; then
		notify "Changing hibernatemode to \033[1msleep-only\033[0m"
		log "hibernatemode => 0 (sleep-only)"
		$PMSET -a hibernatemode 0 >/dev/null 2>&1
	else
		notify "Hibernatemode is \033[1msleep-only\033[0m, no need to change"
		log "hibernatemode is already 0, no need to change"
	fi
else
	if [ $CURR_HIBERNATEMODE != 3 ] ; then
		notify "Changing hibernatemode to \033[1msafe sleep\033[0m"
		log "hibernatemode => 3 (safe sleep)"
		$PMSET -a hibernatemode 3 >/dev/null 2>&1
	else
		notify "Hibernatemode is \033[1msafe sleep\033[0m, no need to change"
		log "hibernatemode is already 3, no need to change"
	fi
fi

