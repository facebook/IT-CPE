#!/bin/bash

function enroll_jamf () {
  # Enroll the user in JAMF
  /usr/sbin/jamf startSSH
  /usr/sbin/jamf createConf -url 'https://casper_server/'
  /usr/sbin/jamf enroll -invitation INSERT_ENROLL_NUMBER
}

