#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function flush_casper_policies {
  # Flush all casper policies

  # Requires elevated privileges to flush policies
  echo "Flushing all Casper Policies..."
  sudo jamf flushPolicyHistory

}
