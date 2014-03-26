#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

function set_local_time {
  # Use Apple's systemsetup utility to set
  # the time on the machine

  # Set using the time server
  systemsetup -setusingnetworktime on
  # Use your company's time server, or maybe time.apple.com
  systemsetup -setnetworktimeserver time.company.com

}
