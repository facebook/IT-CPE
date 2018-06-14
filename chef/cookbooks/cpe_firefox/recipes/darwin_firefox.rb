#
# Cookbook Name:: cpe_firefox
# Recipe:: mac_os_x_firefox
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

return unless node.installed?('org.mozilla.firefox')

node.app_paths('firefox').each do |app_path|
  # We don't want to manage externally mounted volumes
  next if app_path.start_with?('/Volumes/')

  resources_dir = ::File.join(app_path, 'Contents', 'Resources')
  # Skip if this is a broken Firefox install
  next unless Dir.exist?(::File.join(resources_dir, 'defaults'))

  defaults_path = ::File.join(resources_dir, 'defaults', 'pref')
  # This will typically be:
  # /Applications/Firefox.app/Contents/Resources/defaults/pref

  # Set up required directories
  [
    ::File.join(resources_dir, 'defaults'),
    ::File.join(resources_dir, 'defaults', 'pref'),
  ].each do |d|
    directory d do
      owner 'root'
      group 'wheel'
      mode '0775'
      action :create
    end
  end

  # We're going to place the configs in a central directory
  remote_directory "#{app_path}-#{node['cpe_firefox']['ff_central_store']}" do
    path lazy { node['cpe_firefox']['ff_central_store'] }
    source 'firefox'
    owner 'root'
    group 'wheel'
    mode '0775'
    recursive true
  end

  template "#{app_path}-autoconfig.js" do
    source 'autoconfig.js'
    path lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'], 'autoconfig.js')
    }
    owner 'root'
    group 'wheel'
    mode '0644'
  end

  # Apply the new config template
  template "#{app_path}-autoconfig_template" do
    path lazy {
      ::File.join(
        node['cpe_firefox']['ff_central_store'],
        node['cpe_firefox']['cfg_file_name'],
      )
    }
    source 'autoconfig.erb'
    owner 'root'
    group 'wheel'
    mode '0644'
  end

  # Link new autoconfig.js
  link ::File.join(defaults_path, 'autoconfig.js') do
    to lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'], 'autoconfig.js')
    }
  end

  # Link the autoconfig file
  link 'autoconfig.cfg' do
    target_file lazy {
      ::File.join(resources_dir, node['cpe_firefox']['cfg_file_name'])
    }
    to lazy {
      ::File.join(
        node['cpe_firefox']['ff_central_store'],
        node['cpe_firefox']['cfg_file_name'],
      )
    }
  end

  # Link resources folder
  link ::File.join(resources_dir, 'fb-resources') do
    to lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'], 'resources')
    }
  end
end
