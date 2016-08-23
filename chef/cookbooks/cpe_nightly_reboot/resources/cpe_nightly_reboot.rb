# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Cookbook Name:: cpe_nightly_reboot
# Resource:: cpe_nightly_reboot
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

require 'Pathname'

resource_name :cpe_nightly_reboot
default_action :run

action :run do
  # Set up the logout script
  directory Pathname.new(node['cpe_nightly_reboot']['script']).dirname.to_s do
    recursive true
    action :create
  end

  cookbook_file node['cpe_nightly_reboot']['script'] do
    source 'logout_bootstrap.py'
    owner 'root'
    group 'wheel'
    mode '0755'
    action :create
  end

  restart = node['cpe_nightly_reboot']['restart'].reject { |_k, v| v.nil? }
  node.default['cpe_launchd']['com.CPE.reboot'] = {
    'program_arguments' => [
      '/sbin/reboot',
    ],
    'start_calendar_interval' => restart,
  } unless restart.empty?

  logout = node['cpe_nightly_reboot']['logout'].reject { |_k, v| v.nil? }
  node.default['cpe_launchd']['com.CPE.logout'] = {
    'program_arguments' => [
      node['cpe_nightly_reboot']['script'],
    ],
    'start_calendar_interval' => logout,
  } unless logout.empty?
end
