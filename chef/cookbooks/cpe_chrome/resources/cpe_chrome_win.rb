# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_chrome
# Resources:: cpe_chrome_win
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_chrome
provides :cpe_chrome, :os => 'windows'
default_action :config

action :config do
  # check file path for Chrome since osquery doesn't detect
  # chrome is installed on all machines
  chrome_installed = ::File.file?(
    "#{ENV['ProgramFiles(x86)']}\\Google\\Chrome\\Application\\chrome.exe",
  )
  unless node.installed?('Google Chrome') || chrome_installed
    Chef::Log.warn(
      "#{cookbook_name}::#{recipe_name} - Google Chrome not installed.",
    )
    return
  end
  return unless node['cpe_chrome']['profile'].values.any?
  # We've been seeing users running development VMs/hardware that do not have
  # SID because of no intern person data. Also freshly imaged machines do not
  # have intern person data until the laptop is used. So we will (for now) exit
  # out of the cookbook to accomodate that scenario.
  uid = node.person['uid']
  return if uid.nil?

  reg_settings = []
  node['cpe_chrome']['profile'].each do |setting|
    # For some reason these are enumerated as an array with 2 entries, code
    # for the custom class anticipates a Hash. Maybe this is hacky?
    reconstruct_setting = { setting.first => setting.last }
    reg_settings << WindowsChromeSetting.new(reconstruct_setting, false)
  end

  reg_settings.uniq.each do |setting|
    # We cannot reference HKEY_CURRENT_USER directly for the owner of the
    # machine, so instead we use intern person data to find out their AD SID and
    # then replace the HKEY_CURRENT_USER string in the path with the user's SID
    # so we can modify their user preferences in HKEY_USERS
    setting.sid(uid)
    registry_key setting.fullpath do
      values setting.to_chef_reg_provider
      recursive true
      ignore_failure true # TODO: remove when person refactor stuff sorted out
      action :create
    end
  end

  # Cleanup registry settings when values are removed from the node attribute.
  # # TODO 19736300, this is causing imaging to break. Removing until a update
  # is pushed.
  # cpe_chrome_cleanup 'Chrome Cleanup'

  # Apply the Master Preferences file
  master_path =
    'c:\\Program Files (x86)\\Google\\Chrome\\Application\\master_preferences'
  file "delete-#{master_path}" do
    only_if do
      node['cpe_chrome']['mp'][
        'FileContents'].to_hash.reject { |_k, v| v.nil? }.empty?
    end
    path master_path
    action :delete
  end

  [
    'C:\\Program Files (x86)\\Google',
    'C:\\Program Files (x86)\\Google\\Chrome',
    'C:\\Program Files (x86)\\Google\\Chrome\\Application',
  ].each do |dir|
    directory dir do
      action :create
    end
  end

  # Create the Master Preferences file
  file "create-#{master_path}" do
    not_if do
      node['cpe_chrome']['mp']['FileContents'].
        to_hash.
        reject { |_k, v| v.nil? }.
        empty?
    end
    content lazy {
      Chef::JSONCompat.to_json_pretty(
        node['cpe_chrome']['mp']['FileContents'].
        to_hash.
        reject { |_k, v| v.nil? },
      )
    }
    path master_path
    action :create
  end
end
