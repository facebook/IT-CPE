#
# Cookbook Name:: cpe_powermanagement
# Attributes:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

# These keys are named after the keys found in:
# `defaults read /Library/Preferences/SystemConfiguration/com.apple.PowerManagement`
# These keys are the _only_ options supported for management.
# Do not add abritrary keys.

default['cpe_powermanagement']['ACPower'] = {
  'Automatic Restart On Power Loss' => nil,
  'Disk Sleep Timer' => nil,
  'Display Sleep Timer' => nil,
  'Sleep On Power Button' => nil,
  'System Sleep Timer' => nil,
  'Wake On LAN' => nil,
  'RestartAfterKernelPanic' => nil
}

default['cpe_powermanagement']['Battery'] = {
  'Automatic Restart On Power Loss' => nil,
  'Disk Sleep Timer' => nil,
  'Display Sleep Timer' => nil,
  'Sleep On Power Button' => nil,
  'System Sleep Timer' => nil,
  'Wake On LAN' => nil,
  'RestartAfterKernelPanic' => nil
}
