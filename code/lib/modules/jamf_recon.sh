#!/bin/bash

#
#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function jamf_recon {
  # Checks to see if the computer is on the corporate network
  # Then does a jamf recon
  check_corp
  if [ "$check_corp" != "True" ] ; then
    echo "not on corpnet"
    return 1
  fi
  jamf recon
}
