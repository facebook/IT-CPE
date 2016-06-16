#!/bin/bash

#
# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#


function Main () {

# Created By Mike Dodge(http://fb.me/mikedodge04):
#
# Jmaf Verify
#   This script will verify that the client time is correct, that the jamf
#   binary is installed, and that we can do a manual trigger.
#
#  iscasperup manual trigger needs to be made before hand. All it should do is
#  echo up.


  Version="0.2"

  [ -z $autoinit ] && { . /Library/code/lib/modules/autoinit.sh; autoinit; }

  # Ensure the time servers are time.COMPANY.com
  set_local_time

  # Checking for the jamf binary
  if [[ ! -f "/usr/sbin/jamf" ]] ; then
    echo "Binary is missing."
    install_casper
  fi

  # Verifying Permissions
  chflags noschg /usr/sbin/jamf
  chflags nouchg /usr/sbin/jamf
  chown root:wheel /usr/sbin/jamf
  chmod 755 /usr/sbin/jamf

  # Checking if machine can run a manual trigger
  jamf_chk=`/usr/sbin/jamf policy -trigger iscasperup | grep "Script result: up"`
  if [[ -n "$jamf_chk" ]]; then
    echo "Jamf enabled"
    exit
  fi

  # Re-enrolling jamf
  enroll_jamf
  if [ $? -ne 0 ]; then
    echo "Re-installing Binary"
    install_casper
    if [ $? -ne 0]; then
      logger -t jamf_verify "failed to install"
      echo "Error! Failed to install and enroll in Casper!"
    fi
  fi

}

Main 2>&1;  exit
