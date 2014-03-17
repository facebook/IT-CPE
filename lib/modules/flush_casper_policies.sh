#!/bin/bash


function flush_casper_policies {
  # Flush all casper policies

  # Requires elevated privileges to flush policies
  echo "Flushing all Casper Policies..."
  sudo jamf flushPolicyHistory

}
