# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco_install
# Resource:: cpe_choco_configure
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_choco_configure
default_action :change

action_class do
  def blacklist_sources
    node['cpe_choco']['sources'].each do |feed, source_info|
      url = source_info['source']
      if node['cpe_choco']['source_blacklist'].include?(url)
        Chef::Log.warn("[#{cookbook_name}]: #{url} is blacklisted, removing.")
        new_values =
          node['cpe_choco']['sources'].to_h.reject { |k, _| k == feed }
        node.normal['cpe_choco']['sources'] = new_values
      end
    end
  end
end

action :change do
  blacklist_sources

  %w{
    C:\ProgramData\chocolatey
    C:\ProgramData\chocolatey\config
  }.each do |dir|
    directory dir do
      owner 'Administrators'
      rights :read_execute, 'Users'
      rights :full_control, 'Administrators'
      action :create
    end
  end

  template 'C:\ProgramData\chocolatey\config\chocolatey.config' do
    source 'chocolatey.config.erb'
    rights :full_control, ['Administrators', 'SYSTEM']
    rights :read_execute, 'USERS'
    action :create
  end
end
