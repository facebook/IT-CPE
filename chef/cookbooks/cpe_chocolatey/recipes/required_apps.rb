#
# Cookbook Name:: cpe_chocolatey
# Recipe:: chocolatey_required_apps
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

# Global Install List for Windows Machines
choco_managed_installs = {}

choco_managed_installs['chocolatey'] = {
  'name' => 'chocolatey',
  'version' => '0.9.10.2',
  'feed' => node['cpe_chocolatey']['default_feed'],
}

choco_managed_installs['firefox'] = {
  'name' => 'firefox',
  'version' => '47.0',
  'feed' => node['cpe_chocolatey']['default_feed'],
}

choco_managed_installs['git'] = {
  'name' => 'git',
  'version' => '2.9.0',
  'feed' => node['cpe_chocolatey']['default_feed'],
}

choco_managed_installs['GoogleChrome'] = {
  'name' => 'GoogleChrome',
  'version' => '51.0.2704.103',
  'feed' => node['cpe_chocolatey']['default_feed'],
}

# Send package list data to cache file
file "#{node['cpe_chocolatey']['app_cache']}" do
  content choco_managed_installs.to_json
end
