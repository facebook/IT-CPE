# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_nightly_reboot
# Attributes:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

default['cpe_nightly_reboot']['script'] =
  '/opt/chef/scripts/logout_bootstrap.py'

default['cpe_nightly_reboot']['restart'] = {
  'Month' => nil,
  'Day' => nil,
  'Weekday' => nil,
  'Hour' => nil,
  'Minute' => nil,
}

default['cpe_nightly_reboot']['logout'] = {
  'Month' => nil,
  'Day' => nil,
  'Weekday' => nil,
  'Hour' => nil,
  'Minute' => nil,
}
