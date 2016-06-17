#
# Cookbook Name:: cpe_munki
# Recipe:: munkireports
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
# Create necessary directories for munkireports
[
  '/usr/local/munki/postflight.d',
  '/usr/local/munki/preflight.d',
  '/usr/local/munki/preflight.d/cache'
].each do |munki_path|
  directory munki_path do
    mode '0755'
    owner 'root'
    group 'wheel'
    action :create
  end
end

# Copy munkireport files to /usr/local/munki
[
  'munkireport_postflight',
  'munkireport_preflight',
  'munkilib/phpserialize.py',
  'munkilib/reportcommon.py',
  'postflight.d/inventory_add_plugins.py',
  'preflight.d/bluetooth.sh',
  'preflight.d/directoryservice.sh',
  'preflight.d/disk_info',
  'preflight.d/displays.py',
  'preflight.d/filevault_2_status_check.sh',
  'preflight.d/filevaultstatus',
  'preflight.d/localadmin',
  'preflight.d/networkinfo.sh',
  'preflight.d/power.sh',
  'preflight.d/submit.preflight',
  'preflight.d/warranty'
].each do |munki_file|
  cookbook_file "/usr/local/munki/#{munki_file}" do
    source "munkireports/#{munki_file}"
    owner 'root'
    mode 0755
    group 'wheel'
    action :create
  end
end

# Write out MunkiReport plist
munkireport_plist = {
  'BaseUrl'     => node['cpe_munki']['munkireport']['baseurl'],
  'Passphrase'  => node['cpe_munki']['munkireport']['password'],
  'ReportItems' => node['cpe_munki']['munkireport']['report_items']
}
launchd '/Library/Preferences/MunkiReport.plist' do
  path '/Library/Preferences/MunkiReport.plist'
  hash munkireport_plist
  owner 'root'
  group 'wheel'
  mode 0644
  action :create
end
