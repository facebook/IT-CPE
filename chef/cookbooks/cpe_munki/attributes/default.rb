#
# Cookbook Name:: cpe_munki
# Attributes:: default
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

default['cpe_munki']['install'] = false
default['cpe_munki']['configure'] = false
default['cpe_munki']['local']['managed_installs'] = []
default['cpe_munki']['local']['managed_uninstalls'] = []

default['cpe_munki']['munki_version_to_install'] = '2.7.0.2753'

# To shard the rollout of a new version:
# if node.shard_over_a_week_starting('2015-10-26')
#   default['cpe_munki']['munki_version_to_install'] = '2.3.1.2535'
# end

# These are only used if you include the munkireports recipe
default['cpe_munki']['munkireports']['install'] = false
default['cpe_munki']['munkireport']['baseurl'] =
  'https://munkireports.example.com/'
default['cpe_munki']['munkireport']['password'] =
  'hashed_password'
default['cpe_munki']['munkireport']['report_items'] = {
  'bluetooth'         =>
    '/usr/local/munki/preflight.d/cache/bluetoothinfo.txt',
  'directory_service' =>
    '/usr/local/munki/preflight.d/cache/directoryservice.txt',
  'disk_report'       => '/usr/local/munki/preflight.d/cache/disk.plist',
  'display_info'      => '/usr/local/munki/preflight.d/cache/displays.txt',
  'displays_info'     => '/usr/local/munki/preflight.d/cache/displays.txt',
  'filevault_status'  =>
    '/usr/local/munki/preflight.d/cache/filevaultstatus.txt',
  'installhistory'    => '/Library/Receipts/InstallHistory.plist',
  'inventory'         =>
    '/Library/Managed Installs/ApplicationInventory.plist',
  'localadmin'        => '/usr/local/munki/preflight.d/cache/localadmins.txt',
  'munkireport'       =>
    '/Library/Managed Installs/ManagedInstallReport.plist',
  'network'           => '/usr/local/munki/preflight.d/cache/networkinfo.txt',
  'warranty'          => '/usr/local/munki/preflight.d/cache/warranty.txt'
}

default['cpe_munki']['preferences'] = {
  'AppleSoftwareUpdatesOnly'       => false,
  'DaysBetweenNotifications'       => 1,
  'FollowHTTPRedirects'            => 'none',
  'InstallAppleSoftwareUpdates'    => false,
  'LogFile'                        =>
    '/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log',
  'LogToSyslog'                    => false,
  'LoggingLevel'                   => 1,
  'ManagedInstallDir'              => '/Library/Managed Installs',
  'SoftwareRepoURL'                => 'https://munki/repo',
  'SuppressAutoInstall'            => false,
  'SuppressStopButtonOnInstall'    => false,
  'SuppressUserNotification'       => false,
  'UnattendedAppleUpdates'         => false,
  'UseClientCertificate'           => false
}
