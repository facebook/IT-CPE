#!/bin/bash

# Prep:
#   Should be copyied in each of your scripts. I hate coping and pasting but
#   this is the bar minuim you will need to copy to verify that you will have
#   your code/lib avalible. Prep with use code_sync to verify that your code it
#   there and

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
    . $modules/code_sync.sh
    code_sync "$exit_on_failure"
  fi
  # Call start
  . $modules/start.sh; start;

}
