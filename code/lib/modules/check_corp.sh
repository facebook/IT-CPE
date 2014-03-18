#!/bin/bash



function check_corp {
  # Checks to see if on the corporate network
  CORP_URL="internal-host.com"
  check_corp="False"
  ping=`host -W .5 $CORP_URL`

  # If the ping fails - check_corp="False"
  [[ $? -eq 0 ]] && check_corp="True"

  # Check if we are using a test
  [[ -n "$1" ]] && check_corp="$1"
}
