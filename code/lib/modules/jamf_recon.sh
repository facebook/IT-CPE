#!/bin/bash



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
