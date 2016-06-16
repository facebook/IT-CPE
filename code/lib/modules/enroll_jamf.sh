#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

#!/bin/bash

function enroll_jamf () {
  # Enroll the user in JAMF Casper and starts SSH
  # Add your casper server URL below and generate an unlimited invitation
  # id with a quick.add pkg and add replace that id in "INSERT_ENROLL_NUMBER"
  /usr/sbin/jamf startSSH
  /usr/sbin/jamf createConf -url 'https://casper_server/'
  /usr/sbin/jamf enroll -invitation INSERT_ENROLL_NUMBER
}

