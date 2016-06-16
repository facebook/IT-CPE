#  Copyright (c) 2015-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.

#!/bin/bash


function finish () {
  #Cleanup the files that were created by start.sh

  #This is the clean up
  rm $logs/$current_file_name 1> /dev/null 2>&1
  return 0
}
