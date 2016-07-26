# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco
# Recipe:: configure
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

choco_dir = ENV['ChocolateyInstall'].nil? ? \
            "#{ENV['PROGRAMDATA']}\\chocolatey" : ENV['ChocolateyInstall']
script = format('%s\CPE\Chef\config\choco-run.ps1', ENV['WINDIR'])
config_path = "#{choco_dir}\\config\\chocolatey.config"

whyrun_safe_ruby_block 'blacklisted_items' do
  block do
    node['cpe_choco']['sources'].each do |feed, source_info|
      url = source_info['source']
      if node['cpe_choco']['source_blacklist'].include?(url)
        Chef::Log.warn("[#{cookbook_name}]: #{url} is blacklisted, removing.")
        node.default['cpe_choco']['sources'].delete(feed)
      end
    end
  end
  action :run
end

template config_path do
  source 'chocolatey.config.erb'
  rights :full_control, ['Administrators', 'SYSTEM']
  rights :read_execute, 'USERS'
  action :create
end

# Drop chocolatey run file
cookbook_file script do
  source 'choco-run.ps1'
  rights :full_control, ['Administrators', 'SYSTEM']
  rights :read_execute, 'USERS'
  action :create
end

# Create a task scheduled to run chocolatey installs
windows_task 'Chocolatey Updater' do
  user 'SYSTEM'
  command "powershell.exe -executionpolicy bypass -noprofile -file '#{script}'"
  run_level :highest
  frequency :minute
  frequency_modifier 30
  action [:create, :enable]
end
