#
# Cookbook Name:: cpe_firefox
# Recipe:: windows_firefox
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

# Verify the package is installed
extend ::Windows::Helper
firefox_installed =
  !installed_packages.select { |pkg| /Mozilla Firefox/.match(pkg) }.empty?

return unless firefox_installed

# Windows can have both a 64-bit and 32-bit version installed
# So we need to check for each path
# TODO: When Chef supports 64-bit namespaces, switch this back to ENVs
path32 =
  # "#{ENV['ProgramFiles(x86)']}\\Mozilla Firefox"
  'C:\\Program Files (x86)\\Mozilla Firefox'
path64 =
  # "#{ENV['ProgramFiles']}\\Mozilla Firefox"
  'C:\\Program Files\\Mozilla Firefox'
resources_path = []
[
  path32,
  path64,
].each do |exe_path|
  resources_path << exe_path if Dir.exist?(exe_path)
end
pref_path = []
resources_path.each do |res_path|
  pref_path << File.join(res_path, 'defaults', 'pref')
end
required_pref_paths = []
resources_path.each do |res_path|
  required_pref_paths << res_path
  required_pref_paths << File.join(res_path, 'defaults')
  required_pref_paths << File.join(res_path, 'defaults', 'pref')
end
# This will typically be:
# C:\Program Files(x86)\Mozilla Firefox\defaults\pref
# C:\Program Files\Mozilla Firefox\defaults\pref

# Set up required directories
required_pref_paths.each do |req_pref_path|
  directory req_pref_path do
    rights :read, 'Everyone'
    rights :full_control, 'Administrators'
    action :create
  end
end

pref_file = 'firefox_fb_prefs.cfg'
local_settings = 'local-settings.js'

# Delete the existing config file, we're going to replace it
fb_prefs = []
resources_path.each do |path|
  fb_prefs << File.join(
    path,
    pref_file,
  )
end

fb_prefs.each do |fb_pref|
  file fb_pref do
    action :delete
  end
end

# Delete the "local-settings.js" file if it exists
fb_localjs = []
resources_path.each do |path|
  fb_localjs << File.join(
    path,
    'defaults',
    'pref',
    local_settings,
  )
end

fb_localjs.each do |localsettings|
  file localsettings do
    only_if { File.exist?(localsettings) }
    action :delete
  end
end

# Apply the new config template
resources_path.each do |res_path|
  cck2_file = File.join(res_path, 'cck2.cfg')
  template cck2_file do
    source 'cck2.erb'
    rights :read, 'Everyone'
    rights :full_control, 'Administrators'
  end
end

# Windows gets the config installed for either 32, 64 or both
resources_path.each do |res_path|
  remote_directory res_path do
    source 'firefox'
    rights :read, 'Everyone'
    rights :full_control, 'Administrators'
  end
end
