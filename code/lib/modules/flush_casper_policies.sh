#!/bin/bash

#
#  Copyright (c) 2015, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function flush_casper_policies {
  # Flush all JAMF Casper policies

  echo "Flushing all Casper Policies..."
  jamf flushPolicyHistory

}
