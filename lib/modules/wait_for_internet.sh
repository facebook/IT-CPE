#!/bin/bash

function wait_for_internet () {
  # wait_for_internet loop
  # This script will loop util the computer is on the internet or 4 hours has
  # passed. Then it will run the script or func passed.

  Version="2.0"
  logger -t code-wait_for_internet "$@"

  # Loop until the machine is on the network
  check_internet
  while [[ "$check_internet" != "True" ]]; do
    sleep 300
    check_internet
  done

  # Test if nothing is being passed
  if [ -z "$@" ] ; then
    return
  fi

  # Test if func is passed and run
  TEST=`type $@ | grep "is a function"`
  if [ -n "$TEST" ] ; then
    $@
    return
  fi

  # run script with params
  sh $@
}
