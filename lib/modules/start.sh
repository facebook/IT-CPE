#!/bin/bash

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

