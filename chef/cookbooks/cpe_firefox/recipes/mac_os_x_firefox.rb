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

node.default['cpe_munki']['local']['managed_installs'] <<
  'Firefox'

return unless node.installed?('org.mozilla.firefox')

require 'Pathname'

node.app_paths('org.mozilla.firefox').each do |app_path|
  path = Pathname.new(app_path)
  resources_dir = path + 'Contents' + 'Resources'
  # Skip if this is a broken Firefox install
  next unless Dir.exist?(resources_dir + 'defaults')
  defaults_path = resources_dir + 'defaults' + 'pref'
  # This will typically be:
  # /Applications/Firefox.app/Contents/Resources/defaults/pref

  # Set up required directories
  [
    resources_dir.to_s,
    (resources_dir + 'defaults').to_s,
    (resources_dir + 'defaults' + 'pref').to_s,
  ].each do |req_pref_path|
    directory req_pref_path do
      owner 'root'
      group 'admin'
      mode '0775'
      action :create
    end
  end

  pref_file = 'firefox_fb_prefs.cfg'
  local_settings = 'local-settings.js'

  # Delete the old config file
  fb_pref = resources_dir + pref_file
  file fb_pref.to_s do
    action :delete
  end

  # Delete the old local settings file
  local_settings_file = resources_dir + local_settings
  file local_settings_file.to_s do
    action :delete
  end

  # We're going to place the configs in /Library/CPE/browsers/firefox/
  ff_central_store =
    Pathname.new(CPE.get_cpe_path('cpe')) + 'browsers' + 'firefox'
  remote_directory ff_central_store.to_s do
    source 'firefox'
    owner 'root'
    group 'wheel'
    mode '0775'
    recursive true
  end

  # Apply the new config template
  cck2_file = (ff_central_store + 'cck2.cfg').to_s
  template cck2_file do
    source 'cck2.erb'
    owner 'root'
    group 'wheel'
    mode '0644'
  end

  # Delete the old autoconfig.js in the resources directory
  autoconfig_old = (resources_dir + 'autoconfig.js').to_s
  link 'old_autoconfig_link' do
    target_file autoconfig_old
    action :delete
  end

  # Link new autoconfig.js
  autoconfig = defaults_path + 'autoconfig.js'
  new_autoconfig = ff_central_store + 'defaults' + 'pref' + 'autoconfig.js'
  link autoconfig.to_s do
    to new_autoconfig.to_s
  end

  # Link cck2.cfg
  cck2cfg = resources_dir + 'cck2.cfg'
  new_cck2cfg = ff_central_store + 'cck2.cfg'
  link cck2cfg.to_s do
    to new_cck2cfg.to_s
  end

  # Link cck2 folder
  cck2 = resources_dir + 'cck2'
  new_cck2 = ff_central_store + 'cck2'
  link cck2.to_s do
    to new_cck2.to_s
  end
end
