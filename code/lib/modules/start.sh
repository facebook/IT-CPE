#!/bin/bash

#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

# Start:
#  This is were you will add any common setup for all all your scripts. I added
#  auto_init that will source your code/lib and I define the current_file_name
#  as well I echo out a standard message that tells you when the given script
#  was ran, and the verion that you defined with in the script

function start () {
	
  # Run the auto_init
  [ -z $autoinit ] && { . /Library/code/lib/modules/autoinit.sh; autoinit; }

  current_file_name=`basename $0`
  echo -e "\n\n\n\n\n$current_file_name ran on `date "+%m-%d-%Y %H:%M"` \nVersion $Version"

}

