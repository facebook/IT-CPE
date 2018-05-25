#
# Cookbook Name:: cpe_firefox
# Recipe:: linux_firefox
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

return unless ::File.exist?('/usr/bin/firefox')

require 'pathname'

ff_base_path = value_for_platform_family(
  'fedora' => '/usr/lib64/firefox',
  :default => '/usr/lib/firefox',
)
browser_dir = ::File.join(ff_base_path, 'browser')
defaults_dir = ::File.join(browser_dir, 'defaults')
pref_path = ::File.join(defaults_dir, 'preferences')
# This will typically be:
# /usr/lib/firefox/browser/defaults/preferences

# Set up required directories
[
  ff_base_path,
  browser_dir,
  defaults_dir,
  pref_path,
].each do |req_pref_path|
  directory req_pref_path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

# Apply the new config template
fbcfg = ::File.join(ff_base_path, 'facebook.cfg')
template fbcfg do
  source 'facebook.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

fbdir = ::File.join(ff_base_path, 'fb-resources')
remote_directory fbdir do
  source 'firefox/resources'
  owner 'root'
  group 'root'
  mode '0755'
end

acjs = ::File.join(pref_path, 'autoconfig.js')
cookbook_file acjs do
  source 'firefox/defaults/pref/autoconfig.js'
  owner 'root'
  group 'root'
  mode '0644'
end
