#!/bin/sh
# (c) Meta Platforms, Inc. and affiliates. Confidential and proprietary.

HEARTBEAT="/opt/facebook/bin/heartbeat"
TOKEN_FILE="/Library/CPE/var/heartbeat_token.txt"
if [ -x "$HEARTBEAT" ] && [ -f "$TOKEN_FILE" ]; then
  "$HEARTBEAT" --tag munki_runs -token_file "$TOKEN_FILE" &>/dev/null
fi


