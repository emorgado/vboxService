#!/bin/sh
### BEGIN INIT INFO
# Provides:          desenvolvimento
# Required-Start:    $local_fs $remote_fs $network $syslog $named $vboxdrv
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop 
### END INIT INFO

# Author <emerson.morgado@gmail.com>
# 2012-03-22
# version 1.0
# Description Control vm server as a service
# Instructions
# The file name MUST be the virtual box machine name
# Every action performed will generate a log at /var/log/<service_name>
# To add service on LSB init: sudo insserv desenvolvimento
# To remove service of LSB init: sudo inserv -r desenvolvimento
# !important add vboxdrv on the last line of /etc/modules

PATH=/sbin:/bin:/usr/sbin:/usr/bin:$PATH
RETVAL=0;
VBOX_SRV_NAME="${0##*/}"
VBOX_SRV_NAME="${VBOX_SRV_NAME##[KS][0-9][0-9]}"
# Name of the user who has permission on virtualbox
VM_OWNER="emerson"
VM_COMMAND="VBoxManage"
LOG_FILE="/var/log/${VBOX_SRV_NAME}.log"

echo "\n`date` -[${1}]-"  >>${LOG_FILE}
echo $PATH >>${LOG_FILE}
start() {
   echo "Starting Virtual server ${VBOX_SRV_NAME}"
   #su -u "${VM_OWNER} ${VM_COMMAND} startvm --type headless" 1>>$LOG_FILE 2>>$LOG_FILE
   su -lc "${VM_COMMAND} startvm ${VBOX_SRV_NAME} --type headless" ${VM_OWNER} 1>>${LOG_FILE} 2>>${LOG_FILE}
}

stop() {
  echo "Stopping Virtual server ${VBOX_SRV_NAME}"
  su -c "VBoxManage controlvm ${VBOX_SRV_NAME} pause" ${VM_OWNER} 1>>${LOG_FILE} 2>>${LOG_FILE}
  su -c "VBoxManage controlvm ${VBOX_SRV_NAME} poweroff" ${VM_OWNER} 1>>${LOG_FILE} 2>>${LOG_FILE}
}

pause() {
  echo "Pausing Virtual server ${VBOX_SRV_NAME}"
  su -c "VBoxManage controlvm ${VBOX_SRV_NAME} pause" ${VM_OWNER}  1>>${LOG_FILE} 2>>${LOG_FILE}
}

resume() {
  echo "Resuming Virtual server ${VBOX_SRV_NAME}"
  su -c "VBoxManage controlvm ${VBOX_SRV_NAME} resume" ${VM_OWNER}  1>>${LOG_FILE} 2>>${LOG_FILE} 
}

force_reload() {
  echo "Force reload disabled for Virtual server ${VBOX_SRV_NAME}"
}

restart() {
  stop
  start
}

savestate(){
  echo "Saving Virtual server ${VBOX_SRV_NAME} state"
  STATE=""
  su -c "VBoxManage controlvm ${VBOX_SRV_NAME} savestate" ${VM_OWNER} 1>>${LOG_FILE} 2>>${LOG_FILE} 

}

status(){
  echo "Getting Virtual server ${VBOX_SRV_NAME} status"
  VM_STATE=  su -c "${VM_COMMAND} showvminfo ${VBOX_SRV_NAME} | grep State" ${VM_OWNER}  
  #VM_STATE= su -u "${VBOX_OWNER} ${VBOX_COMMAND} showvminfo | grep State" 
  #1>>$VM_STATE 2>>$VM_STATE
  echo "${VM_STATE}"
  echo "${VM_STATE}">>$LOG_FILE 
}

command_exists () {
  type "$1" &> /dev/null;
}

log () {
	#SG=1>
	1>>${LOG_FILE}
}

# --------

case "$1" in
start)
  start
;;
stop)
  stop
;;
restart)
  restart
;;
pause)
  pause
;;
resume)
  resume
;;
force_reload)
  force_reload
;;
savestate)
  savestate
;;
status)
  status
;;
*)
echo "Usage: # service ${VBOX_SRV_NAME} {start|stop|restart|pause|resume|force_reload|savestate|status}"
exit 1
esac

exit $RETVAL
