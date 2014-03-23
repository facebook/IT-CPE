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
# Launch Daemon Init installer:
#   This installs the needed Launch Daemons for LDI.
#
#   $schedule:
#     is passed from a corresponding launch daemon and can be
#     startup, every15, hourly, daily, weekly
#   ldi_[sh/py/func]_run:
#     Depending on the script you are passing. You will use sh or py or fun.
#     This takes care of the logging and general run syntax
#   ldi_logger:
#     runs a logger command, that writes a standard message to syslog

Version="1.1"

prep


startup_plist='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.code.startup</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/code/lib/scripts/launch_daemon_init.sh</string>
		<string>startup</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
    <key>TimeOut</key>
    <integer>14400</integer>
</dict>
</plist>'

every_15_plist='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.code.every15</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/code/lib/scripts/launch_daemon_init.sh</string>
		<string>every15</string>
	</array>
	<key>StartInterval</key>
	<integer>900</integer>
    <key>TimeOut</key>
    <integer>14400</integer>
</dict>
</plist>'

hourly_plist='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.code.hourly</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/code/lib/scripts/launch_daemon_init.sh</string>
		<string>hourly</string>
	</array>
	<key>StartInterval</key>
	<integer>3600</integer>
    <key>TimeOut</key>
    <integer>14400</integer>
</dict>
</plist>'

daily_plist='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.code.daily</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/code/lib/scripts/launch_daemon_init.sh</string>
		<string>daily</string>
	</array>
	<key>StartCalendarInterval</key>
	<dict>
        <key>Hour</key>
        <integer>10</integer>
    </dict>
    <key>TimeOut</key>
    <integer>14400</integer>
</dict>
</plist>'

weekly_plist='<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.code.weekly</string>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/code/lib/scripts/launch_daemon_init.sh</string>
		<string>weekly</string>
	</array>
	<key>StartInterval</key>
	<integer>604800</integer>
    <key>TimeOut</key>
    <integer>14400</integer>
</dict>
</plist>'


# Unload any code LaunchDaemons
launchctl unload -w /Library/LaunchDaemons/com.code.* &>/dev/null

sleep 3

# Creating Plists
echo "$startup_plist"   > /Library/LaunchDaemons/com.code.startup.plist
echo "$every_15_plist"  > /Library/LaunchDaemons/com.code.every15.plist
echo "$hourly_plist"    > /Library/LaunchDaemons/com.code.hourly.plist
echo "$daily_plist"     > /Library/LaunchDaemons/com.code.daily.plist
echo "$weekly_plist"    > /Library/LaunchDaemons/com.code.weekly.plist

# Set 444 perms
chmod 444 /Library/LaunchDaemons/com.code.* &>/dev/null

sleep 3

# Load Plists
launchctl load -w /Library/LaunchDaemons/com.code.* &>/dev/null

finish

}

#########################################################
###               Supplement Functions                ###
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


Main 2>&1 ; exit

