# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_munki
# Attributes:: default
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
default['cpe_munki']['prompt']['time'] = {}
default['cpe_munki']['auto_remediate'] = nil

default['cpe_munki']['munki_version_to_install']['admin'] = {
  'version' => '2.8.2.2855',
  'checksum' =>
    'b1dfab12f129403f29dd1e9879fe0226f926cdd322cca542c085af7b09e2f474',
}
default['cpe_munki']['munki_version_to_install']['app'] = {
  'version' => '4.2.2842',
  'checksum' =>
    'c4e7bfd324087dec72b6812af9aa38426b335ab641358479984046a378589f8c',
}
# This does not exist for 2.8.2, but when we move to 3, we'll need this
# default['cpe_munki']['munki_version_to_install']['app_usage'] = {
#   'version' => '3.0.0.3320',
#   'checksum' =>
#     'c21ec1eb6edcf11c47abebffd42fc4fd6041012c625bf2337d50ea9654e4c1c0',
# }
default['cpe_munki']['munki_version_to_install']['core'] = {
  'version' => '2.8.2.2855',
  'checksum' =>
    '9361a62a0ba64ef6a574cdd1127190fa0addb88c6b1a111031716489bc340585',
}
default['cpe_munki']['munki_version_to_install']['launchd'] = {
  'version' => '2.0.0.1969',
  'checksum' =>
    '2c95766e8985b4c1b4a6b67d1b0efd92f446ec7d3ae8d85773172164c205e508',
}

default['cpe_munki']['preferences'] = {
  'AppleSoftwareUpdatesOnly' => false,
  'DaysBetweenNotifications' => 1,
  'FollowHTTPRedirects' => 'none',
  'InstallAppleSoftwareUpdates' => false,
  'LogFile' => '/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log',
  'LoggingLevel' => 1,
  'LogToSyslog' => false,
  'PerformAuthRestarts' => false,
  'RecoveryKeyFile' => nil,
  'SoftwareRepoURL' => 'https://munki/repo',
  'SuppressAutoInstall' => false,
  'SuppressStopButtonOnInstall' => false,
  'SuppressUserNotification' => false,
  'UnattendedAppleUpdates' => false,
  'UseClientCertificate' => false,
  'UseNotificationCenterDays' => nil,
}
