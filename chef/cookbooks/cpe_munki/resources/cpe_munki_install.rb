#
# Cookbook Name:: cpe_munki_install
# Resource:: cpe_munki_install
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

resource_name :cpe_munki_install
default_action :install

action :install do
  return unless node['cpe_munki']['install']
  version_to_install = node['cpe_munki']['munki_version_to_install']
  munki = node['cpe_munki'][version_to_install]
  munki_core_version = munki['munki_core_version']

  munki['munki_core_folders'].each do |item|
    directory item do
      action :create
      group 'wheel'
      mode '755'
      owner 'root'
    end
  end

  munki['munki_core_files'].each do |item|
    cookbook_file item do
      not_if { ::File.exist?('/Library/CPE/tags/munki_test') }
      action :create
      group 'wheel'
      mode '755'
      owner 'root'
      source "munki/core/#{munki_core_version}/#{item}"
    end
  end

  munki_admin_version = munki['munki_admin_version']
  munki['munki_admin_folders'].each do |item|
    directory item do
      action :create
      group 'wheel'
      mode '755'
      owner 'root'
    end
  end

  munki['munki_admin_files'].each do |item|
    cookbook_file item do
      not_if { ::File.exist?('/Library/CPE/tags/munki_test') }
      action :create
      group 'wheel'
      mode '755'
      owner 'root'
      source "munki/admin/#{munki_admin_version}/#{item}"
    end
  end

  munki_ld_version = munki['munki_launchd_version']

  munki['munki_launchd_folders'].each do |item|
    directory item do
      action :create
      group 'wheel'
      mode 0o755
      owner 'root'
    end
  end

  munki['munki_launcha_files'].each do |item|
    launcha_path = "/Library/LaunchAgents/#{item}"
    cookbook_file launcha_path do
      not_if { ::File.exist?('/Library/CPE/tags/munki_test') }
      action :create
      group 'wheel'
      mode '755'
      owner 'root'
      source "munki/launchd/#{munki_ld_version}/Library/LaunchAgents/#{item}"
    end

    launcha = item.sub('.plist', '')
    launchd launcha do # ~FC022
      not_if { node.console_user.include?('root') }
      only_if { item.include?('ManagedSoftwareCenter') }
      action :enable
      path launcha_path
    end
  end

  munki['munki_ld_files'].each do |item|
    launchd_path = "/Library/LaunchDaemons/#{item}"
    cookbook_file launchd_path do
      not_if { ::File.exist?('/Library/CPE/tags/munki_test') }
      action :create
      group 'wheel'
      mode '755'
      owner 'root'
      source "munki/launchd/#{munki_ld_version}/Library/LaunchDaemons/#{item}"
    end

    munki_launchd = item.sub('.plist', '')
    launchd munki_launchd do
      action :enable
      path launchd_path
    end
  end

  cpe_remote_pkg 'Managed Software Center' do
    app 'munkitools_app'
    checksum munki['munki_app_checksum']
    receipt 'com.googlecode.munki.app'
    version munki['munki_app_version']
  end
end
