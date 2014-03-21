#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function wait_for_corp () {
  # wait_for_corp loop
<<<<<<< HEAD
  # This script will loop until the computer is on the corporate network or 4
  # hours have passed. Then it will run the script or function passed.
=======
  # This script will loop until the computer is on the corperate network.
  # Then it will run the script or function passed.
>>>>>>> FETCH_HEAD

  Version="2.0"
  logger -t code-wait_for_corp "$@"

  # Loop until the machine is on the corp_network
  check_corp
  while [[ "$check_corp" != "True" ]]; do
    sleep 300
    check_corp
  done

  # Test if nothing is being passed
  if [ -z "$@" ] ; then
    return
  fi

  # Test if func is passed and run
  TEST=`type $@ | grep "is a function"`
  if [ -n "$TEST" ] ; then
    $@
    return
  fi

  # run script with params
  sh $@
}


