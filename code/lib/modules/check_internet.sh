#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function check_internet {
  # Checks to see if on the internet
  # Input: Optional ($1) contains a parameter that is used for testing.
  # Output: Returns "True" if URL variable is pingable, "False" otherwise.
  # If a parameter is passed ($1), the check_internet variable will return it
  # This is useful for testing scripts where you want to force check_corp
  # to be either "True" or "False"
  URL="facebook.com"
  check_internet="False"
  ping=`host -W .5 $URL`

  # If the ping fails - check_internet="False"
  [[ $? -eq  0 ]] && check_internet="True"

  # Check if we are using a test
  [[ -n "$1" ]] && check_internet="$1"
}
