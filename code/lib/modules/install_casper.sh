#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

#!/bin/bash


function install_casper {
  # Installs Casper with a quickadd.pkg on local machine. Enter the path
  # to the QA (QuickAdd.pkg) below.  This should be hosted on any type of
  # file share.

  PATH_TO_QA_PkG=""

  echo "Installing Casper..."
  echo "This will take a few minutes..."

  # Clear the user and system immutable flags - Prevents user and system
  # file locks. Change ownership of jamf binary to root wheel and set 
  # proper permissions
  if [[ -f "/usr/sbin/jamf" ]] ; then
    chflags noschg /usr/sbin/jamf
    chflags nouchg /usr/sbin/jamf
    chown root:wheel /usr/sbin/jamf
    chmod 755 /usr/sbin/jamf
  fi

  # Installs the quickadd.pkg
  installer -pkg $PATH_TO_QA_PKG -target / &> /dev/null

  # Echo errors if there are any
  if [[ $? -ne 0 ]]; then
    print_red "Install failed"
    exit 1
  fi
}

