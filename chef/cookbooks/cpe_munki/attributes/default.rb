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

default['cpe_munki']['munki_version_to_install'] = '2.8.0.2807'

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
  'UseClientCertificate'           => false,
}
