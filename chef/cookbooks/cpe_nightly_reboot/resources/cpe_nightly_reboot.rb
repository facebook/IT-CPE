# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8
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
  # Convert this to the node_utils function: t13016462
  path = Pathname.new(node['cpe_nightly_reboot']['script'])
  dirlist = []
  path.parent.ascend { |v| dirlist << v.to_s unless v.to_s == '/' }
  dirlist.reverse_each do |dir|
    directory dir do
      action :create
    end
  end

  cookbook_file node['cpe_nightly_reboot']['script'] do
    source 'logout_bootstrap.py'
    owner 'root'
    group 'wheel'
    mode '0755'
    action :create
  end

  # Set up the launchds
  restart_launchd = {
    'program_arguments' => [
      '/sbin/reboot',
    ],
    'start_calendar_interval' => {},
  }

  logout_launchd = {
    'program_arguments' => [
      node['cpe_nightly_reboot']['script'],
    ],
    'start_calendar_interval' => {},
  }

  interval =
    node['cpe_nightly_reboot']['restart'].reject { |_k, v| v.nil? }
  unless interval.empty?
    restart_launchd['start_calendar_interval'] = interval
    node.default['cpe_launchd']['com.CPE.reboot'] =
      restart_launchd
  end
  logout = node['cpe_nightly_reboot']['logout'].reject { |_k, v| v.nil? }
  unless logout.empty? ||
         !::File.exist?(node['cpe_nightly_reboot']['script'])
    logout_launchd['start_calendar_interval'] = logout
    node.default['cpe_launchd']['com.CPE.logout'] =
      logout_launchd
  end
end
