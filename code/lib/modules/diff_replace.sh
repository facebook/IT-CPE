#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

# Created By Ajay Chand(http://fb.me/achand27)
#
# Updates a configuration file with a file from the code repo
# Makes a backup of the original local conf to .code.bak
# Input: $1 is local path to ini file, $2 is code path to ini file
# Output: outputs the date the file was replaced
# Sample Usage: diff_replace "/etc/krb5.conf" "/Library/code/lib/kerberos/krb5.conf"


function diff_replace() {

  local_conf="$1"
  code_lib_conf="$2"

  if [ ! -f "$code_lib_conf" ] ; then
    echo "$code_lib_conf does not exist"
    return 1
  fi

  if diff -q "$code_lib_conf" "$local_conf" &> /dev/null; then
    # files are the same
    return 0
  fi

  # Making a backup
  if [ -f "$local_conf" ] ; then
    cp -f "$local_conf" "${local_conf}".code.bak
  fi

  chmod -f 744 "$local_conf" &> /dev/null
  echo "$( (cp -v -f "$code_lib_conf" "$local_conf") 2>&1)"
  chmod -f 644 "$local_conf"
}
