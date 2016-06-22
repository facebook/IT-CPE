#
# Cookbook Name:: cpe_chocolatey
# Recipe:: chocolatey_configure
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

# Drop choco config file
cookbook_file "#{node['cpe_chocolatey']['config']}" do
  source 'chocolatey.config'
  rights :full_control, ['Administrators', 'SYSTEM'],
    :applies_to_children => true
  rights :read_execute, 'USERS', :applies_to_children => true
end

# Drop chocolatey run file
cookbook_file "#{node['cpe_chocolatey']['choco_run']}" do
  source 'choco-run.ps1'
  rights :full_control, ['Administrators', 'SYSTEM'],
    :applies_to_children => true
  rights :read_execute, 'USERS', :applies_to_children => true
end

# Create a task scheduled to run chocolatey installs
windows_task 'Chocolatey Updater' do
  user 'SYSTEM'
  command "powershell.exe -executionpolicy bypass -noprofile -file #{node['cpe_chocolatey']['choco_run']}"
  run_level :highest
  frequency :minute
  frequency_modifier 30
  action [:create, :enable]
end
