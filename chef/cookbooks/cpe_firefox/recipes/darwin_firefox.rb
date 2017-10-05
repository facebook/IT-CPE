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

unless node.type?(['lobby', 'reception', 'wayfinder'])
  node.default['cpe_munki']['local']['managed_installs'] <<
    'Firefox'
end

return unless node.installed?('org.mozilla.firefox')

node.app_paths('org.mozilla.firefox').each do |app_path|
  resources_dir = ::File.join(app_path, 'Contents', 'Resources')
  # Skip if this is a broken Firefox install

  next unless Dir.exist?(::File.join(resources_dir, 'defaults'))
  defaults_path = ::File.join(resources_dir, 'defaults', 'pref')
  # This will typically be:
  # /Applications/Firefox.app/Contents/Resources/defaults/pref

  # Set up required directories
  directory resources_dir do
    recursive true
    owner 'root'
    group 'admin'
    mode '0775'
    action :create
  end

  # Delete the old configs
  [
    ::File.join(resources_dir, 'firefox_fb_prefs.cfg'),
    ::File.join(resources_dir, 'local-settings.js'),
  ].each do |old_config|
    file old_config do
      action :delete
    end
  end

  # Delete the old local settings file
  file ::File.join(resources_dir, 'local-settings.js') do
    action :delete
  end

  # We're going to place the configs in a central directory

  remote_directory 'remote_directory' do
    path lazy { node['cpe_firefox']['ff_central_store'] }
    source 'firefox'
    owner 'root'
    group 'wheel'
    mode '0775'
    recursive true
  end

  # Apply the new config template
  template 'cck2_template' do
    path lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'], 'cck2.cfg')
    }
    source 'cck2.erb'
    owner 'root'
    group 'wheel'
    mode '0644'
  end

  # Delete the old autoconfig.js in the resources directory
  autoconfig_old = ::File.join(resources_dir, 'autoconfig.js')
  link 'old_autoconfig_link' do
    target_file autoconfig_old
    action :delete
  end

  # Link new autoconfig.js
  link ::File.join(defaults_path, 'autoconfig.js') do
    to lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'],
                  'defaults', 'pref', 'autoconfig.js')
    }
  end

  # Link cck2.cfg
  link ::File.join(resources_dir, 'cck2.cfg') do
    to lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'], 'cck2.cfg')
    }
  end

  # Link cck2 folder
  link ::File.join(resources_dir, 'cck2') do
    to lazy {
      ::File.join(node['cpe_firefox']['ff_central_store'], 'cck2')
    }
  end
end
