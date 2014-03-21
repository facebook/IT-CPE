#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#


function Main () {

# Created By Mike Dodge(http://fb.me/mikedodge04):
#
# Launch Daemon Init:
<<<<<<< HEAD
#   This is where we launch any scripts that we need to run as a launch_daemon.
=======
#   This is where we launch any scripts that we need to run as a launch_demon.
>>>>>>> FETCH_HEAD
#   Every thing we put here will run 2.5 mins after boot or as scheduled.
#
#   $schedule:
#     is passed from a corresponding launch daemon and can be
#     startup, every15, hourly, daily, weekly
#   ldi_[sh/py/func]_run:
#     Depending on the script you are passing. You will use sh or py or func.
#     This takes care of the logging and general run syntax
#   ldi_logger:
#     runs a logger command, that writes a standard message to syslog

Version="1.2"
schedule="$1"
logger_tag="code-ldi"

[ -z $autoinit ] && { . /Library/code/lib/modules/autoinit.sh; autoinit; }

# Only prep on startup or weekly
if [[ "$schedule" = "startup" ]] || [[ "$schedule" = "weekly" ]]; then
  # Make sure to give the machine time to boot
  sleep 150
  prep
fi

case $schedule in
  "startup")
    ldi_func_run "wait_for_corp" "$scripts/jamf_verify.sh"
    ldi_func_run "jamf_recon"
    ;;
  "every15")
    ldi_logger
    ;;
  "hourly")
    ldi_logger
    ;;
  "daily")
    # Delay running of daily up to 4hrs based of delay_value
    delay_value=$(((RANDOM % 14400 )+ 1))
    ldi_logger "Delaying for $(($delay_value/60)) minutes"
    sleep $delay_value
    ldi_func_run "wait_for_corp" "jamf_recon"
    ;;
  "weekly")
    ldi_func_run "wait_for_corp" "$scripts/jamf_verify.sh"
    ;;
  * )
    ldi_logger "Error: Invalid schedule value"
    ;;
esac

finish

}

#########################################################
###               Supliment Functions                 ###
#########################################################

function prep () {
  # Prep to run the script, make sure we have the latest code before sourceing
  # the code/lib and setup up and pre conditions.
  exit_on_failure="noexit"
  [[ "$1" = "exit" ]] && exit_on_failure="exit"

  [[ -z "$lib" ]] && lib="/Library/code/lib"
  [[ -z "$modules" ]] && modules="$lib/modules"

  if [ ! -f $modules/code_sync.sh ]; then
    # Validate the https certs &
    # Update the local machine code lib
    sudo jamf policy -trigger "sync_lib_manual" &>/dev/null
    [ $? -ne 0 ] && { echo "Error: Unable to sync the local lib"; return 1; }
  else
    # Source and call code_sync
    source $modules/code_sync.sh
    code_sync "$exit_on_failure"
  fi
  # Call start
  . $modules/start.sh; start;
}

function ldi_logger () {
  # Log Ldi acctions to syslog
  SCRIPT_NAME="$1"
  logger -t $logger_tag "$schedule $SCRIPT_NAME"
}

function ldi_sh_run (){
  # Run a bash script and log to syslog
  SCRIPT_PATH="$1"
  SCRIPT_NAME=`basename "$1"`
  SCRIPT_WITH_PARAMS="$@"
  ldi_logger "$SCRIPT_NAME"
  TEST=`echo $SCRIPT_NAME| grep "sh"`
  [ -z "$TEST" ] && { echo "Please pass a shell script: $1"; exit 1; }
  sh $SCRIPT_WITH_PARAMS
}

function ldi_func_run (){
  # Run a bash function and log to syslog
  FUNC="$1"
  FUNC_WITH_PARAMS="$@"
  ldi_logger "$FUNC_WITH_PARAMS"
  TEST=`type "$FUNC" | grep "is a function"`
  [ -z "$TEST" ] && { echo "Please pass a shell func: $1"; exit 1; }
  $FUNC_WITH_PARAMS
}

function ldi_py_run (){
  # Run a python script and log to syslog
  SCRIPT_PATH="$1"
  SCRIPT_NAME=`basename "$1"`
  ldi_logger "py $SCRIPT_NAME"
  TEST=`echo $SCRIPT_NAME| grep "py"`
  [ -z "$TEST" ] && { echo "Please pass a python script: $1"; exit 1; }
  python "$SCRIPT_PATH"
}


Main $@ 2>&1


exit



