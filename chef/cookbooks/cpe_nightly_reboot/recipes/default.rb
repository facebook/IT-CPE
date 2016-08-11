# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_nightly_reboot
# Recipe:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

restart_launchd = {
  'program_arguments' => [
    '/sbin/reboot'
  ],
  'start_calendar_interval' => {}
}

logout_launchd = {
  'program_arguments' => [
    '/Library/CPE/lib/flib/scripts/logout_bootstrap.py'
  ],
  'start_calendar_interval' => {}
}

interval_hash = {}
logout_hash = {}

ruby_block 'restart' do
  block do
    interval_hash =
      node['cpe_nightly_reboot']['restart'].reject { |_k, v| v.nil? }
    unless interval_hash.empty?
      restart_launchd['start_calendar_interval'] = interval_hash
      node.default['cpe_launchd']['com.CPE.reboot'] =
        restart_launchd
    end
    logout_hash = node['cpe_nightly_reboot']['logout'].reject { |_k, v| v.nil? }
    unless logout_hash.empty?
      logout_launchd['start_calendar_interval'] = logout_hash
      node.default['cpe_launchd']['com.CPE.logout'] =
        logout_launchd
    end
  end
  action :run
end
