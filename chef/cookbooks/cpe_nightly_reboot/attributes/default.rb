# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_nightly_reboot
# Attributes:: default
#
# Copyright 2016, Facebook CPE
#
# All rights reserved - Do Not Redistribute
#

default['cpe_nightly_reboot']['restart'] = {
  'Month' => nil,
  'Day' => nil,
  'Weekday' => nil,
  'Hour' => nil,
  'Minute' => nil
}

default['cpe_nightly_reboot']['logout'] = {
  'Month' => nil,
  'Day' => nil,
  'Weekday' => nil,
  'Hour' => nil,
  'Minute' => nil
}
