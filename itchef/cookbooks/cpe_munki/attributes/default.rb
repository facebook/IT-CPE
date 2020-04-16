# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Cookbook Name:: cpe_munki
# Attributes:: default

default['cpe_munki'] = {
  'install' => false,
  'configure' => false,
  'auto_remediate' => nil,
  'skip_enforcing_launchds' => [],
  'munki_version_to_install' => {},
  'local' => {
    'managed_installs' => [],
    'managed_uninstalls' => [],
    'optional_installs' => [],
  },
  'preferences' => {
    'AppleSoftwareUpdatesOnly' => nil,
    'DaysBetweenNotifications' => nil,
    'FollowHTTPRedirects' => nil,
    'InstallAppleSoftwareUpdates' => nil,
    'LogFile' => nil,
    'LoggingLevel' => nil,
    'LogToSyslog' => nil,
    'PerformAuthRestarts' => nil,
    'RecoveryKeyFile' => nil,
    'SoftwareRepoURL' => nil,
    'SuppressAutoInstall' => nil,
    'SuppressStopButtonOnInstall' => nil,
    'SuppressUserNotification' => nil,
    'UnattendedAppleUpdates' => nil,
    'UseClientCertificate' => nil,
    'UseNotificationCenterDays' => nil,
  },
}

# # Example of what to set in your company_init.rb
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
