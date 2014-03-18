#!/bin/bash

function set_local_time {
  # Use Apple's systemsetup utility to set
  # the time on the machine

  # Set using the time server
  systemsetup -setusingnetworktime on
  # Use your company's time server, or maybe timw.apple.com
  systemsetup -setnetworktimeserver time.company.com

}
