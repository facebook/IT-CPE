#
# Cookbook Name:: cpe_firefox
# Recipe:: debian_firefox
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

return unless File.exist?('/usr/bin/firefox')

require 'pathname'

resources_dir = Pathname.new('/usr/lib/firefox')
pref_path = resources_dir + 'defaults' + 'pref'
# This will typically be:
# /usr/lib/firefox/defaults/pref

# Set up required directories
[
  resources_dir.to_s,
  (resources_dir + 'defaults').to_s,
  (resources_dir + 'defaults' + 'pref').to_s
].each do |req_pref_path|
  directory req_pref_path do
    owner 'root'
    group 'root'
    mode 0775
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

# Apply the new config template
cck2 = resources_dir + 'cck2.cfg'
template cck2.to_s do
  source 'cck2.erb'
  owner 'root'
  group 'root'
  mode 0644
end

cck2dir = resources_dir + 'cck2'
remote_directory cck2dir.to_s do
  source 'firefox/cck2'
  owner 'root'
  group 'root'
  mode 0755
end

acjs = pref_path + 'autoconfig.js'
cookbook_file acjs.to_s do
  source 'firefox/defaults/pref/autoconfig.js'
  owner 'root'
  group 'root'
  mode 0644
end
