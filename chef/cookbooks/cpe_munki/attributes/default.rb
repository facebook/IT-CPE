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

default['cpe_munki'] = {
  'install' => false,
  'configure' => false,
  'auto_remediate' => nil,
}
default['cpe_munki']['local'] = {
  'managed_installs' => [],
  'managed_uninstalls' => [],
  'optional_installs' => [],
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

node.default['cpe_munki']['munki_version_to_install'] = {}

# # Example of what we set in our company_init.rb
# node.default['cpe_munki']['munki_version_to_install']['admin'] = {
#   'version' => '3.0.0.3333',
#   'checksum' =>
#     '42fb19dbaa1d24691a596a3d60e900f57d2b9d6e1a8018972fe4c52c2f988682',
# }
# node.default['cpe_munki']['munki_version_to_install']['app'] = {
#   'version' => '4.6.3330',
#   'checksum' =>
#   'f1354f99bececdabc0549531e50e1362a332a8e4802a07066e6bc0e74b72258d',
# }
# node.default['cpe_munki']['munki_version_to_install']['app_usage'] = {
#   'version' => '3.0.0.3333',
#   'checksum' =>
#   'bc3299823d024982122de3d98905d28d6bf36585b060f7a0526a591c45815ad4',
# }
# node.default['cpe_munki']['munki_version_to_install']['core'] = {
#   'version' => '3.0.0.3333',
#   'checksum' =>
#   'd82dd386d7aebe459314b7d62da993732e2b1e08813f305fab08ece10e2e330d',
# }
# node.default['cpe_munki']['munki_version_to_install']['launchd'] = {
#   'version' => '3.0.3265',
#   'checksum' =>
#   'b3871f6bb3522ce5e46520bcab06aed2644bf11265653f6114a0e34911f17914',
# }
