#!/bin/bash

#
#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function check_corp {
  # check_corp:
  #   This script verifies a system is on the corporate network.
  #   Input: CORP_URL= set this to a hostname on your corp network
  #   Optional ($1) contains a parameter that is used for testing.
  #   Output: Returns a check_corp variable that will return "True" if on 
  #   corp network, "False" otherwise.
  #   If a parameter is passed ($1), the check_corp variable will return it
  #   This is useful for testing scripts where you want to force check_corp
  #   to be either "True" or "False"
  # USAGE: 
  #   check_corp        # No parameter passed
  #   check_corp "True"  # Parameter of "True" is passed and returned

  CORP_URL="internal-host.com"
  check_corp="False"
  ping=`host -W .5 $CORP_URL`

  # If the ping fails - check_corp="False"
  [[ $? -eq 0 ]] && check_corp="True"

  # Check if we are using a test
  [[ -n "$1" ]] && check_corp="$1"
}
