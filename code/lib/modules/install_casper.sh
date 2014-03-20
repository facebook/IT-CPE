#!/bin/bash


function install_casper {

  PATH_TO_QA_PkG=""

  echo "Installing Casper..."
  echo "This will take a few minutes..."

  # Verifying Permissions
  if [[ -f "/usr/sbin/jamf" ]] ; then
    chflags noschg /usr/sbin/jamf
    chflags nouchg /usr/sbin/jamf
    chown root:wheel /usr/sbin/jamf
    chmod 755 /usr/sbin/jamf
  fi

  installer -pkg $PATH_TO_QA_PKG -target / &> /dev/null

  if [[ $? -ne 0 ]]; then
    print_red "Install failed"
    exit 1
  fi
}

