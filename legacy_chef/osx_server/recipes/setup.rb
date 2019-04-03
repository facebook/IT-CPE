#
# Cookbook Name:: osx_server
# Recipe:: setup
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

# SYSTEM & ACCOUNT SETUP
# Create the cpeserver account
user 'cpeserver' do
  comment 'cpeserver'
  gid 'admin'
  home '/Users/cpeserver'
  shell '/bin/bash'
  password 'f812f03aafe9a6eb1a25f98792a930e2a50bfa87223e33d77886d39acd71ca8f7' +
           'fd85ca8c854d2b6666cb5b48b46ba361bfd3ad6b9dfec89a53a497187ad01d516' +
           '36613078f048840272c119dbd35c6d95a3b697d2e48d33f716914a91b1ce07b04' +
           '4dc53ab40e0cacb6ad7a1325d60990344449f11225099e4f79dec0f284f35'
  salt '33697d2302b7f42a53b57bd380dd756bdfe73a29b336cbb2de9c7b7400d7893f'
  iterations 25_000
  supports manage_home: true
  action :create
end

# Create directory for images
directory node['cpe']['imaging_servers']['netboot_dir'] do
  recursive true
  owner 'root'
  group 'wheel'
  mode 0755
  action :create
end

# Rename hard drive to ServerHD
drive_name = Mixlib::ShellOut.new(
  'diskutil info /'
).run_command.stdout.lines.select { |line| line.include?('Volume Name') }[0]
execute 'Rename hard drive' do
  not_if { drive_name.include?('ServerHD') }
  command 'diskutil rename / ServerHD'
end

# Enable auto login for cpeserver
cpe_remote_file 'kcpassword' do
  file_name 'imaging_server_kcpassword'
  checksum '40450673a43516d5e996763d7f0aa49322297c0c9d4301410b9adfb04cd6f9a3'
  path '/etc/kcpassword'
end

mac_os_x_userdefaults 'Enable auto-login for cpeserver' do
  domain '/Library/Preferences/com.apple.loginwindow'
  key 'autoLoginUser'
  value 'cpeserver'
end

# Install the Profile for the dock
file_name = 'Imaging_server_dock.mobileconfig'
profile_name = 'com.cpe.imaging_server.dock'

cpe_utils_mobileconfig_profile file_name do
  identifier profile_name
  source file_name
  action :install
end

# Energy settings
plist_name = 'com.apple.PowerManagement.plist'
plist_location = "/Library/Preferences/SystemConfiguration/#{plist_name}"
cookbook_file plist_location do
  source plist_name
  mode 0644
  owner 'root'
  group 'wheel'
end
