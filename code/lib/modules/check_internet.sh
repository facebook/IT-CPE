#!/bin/bash



function check_internet {
  # Checks to see if on the internet
  URL="facebook.com"
  check_internet="False"
  ping=`host -W .5 $URL`

  # If the ping fails - check_internet="False"
  [[ $? -eq  0 ]] && check_internet="True"

  # Check if we are using a test
  [[ -n "$1" ]] && check_internet="$1"
}
