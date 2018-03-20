# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8

# Cookbook Name:: cpe_munki
# Resource:: cpe_munki_config
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_munki_config
default_action :config

action :config do
  return unless node['cpe_munki']['configure']

  munki_prefs = node['cpe_munki']['preferences'].reject { |_k, v| v.nil? }
  if munki_prefs.empty?
    Chef::Log.info("#{cookbook_name}: No prefs found.")
    return
  end

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'

  munki_profile = {
    'PayloadIdentifier' => "#{prefix}.munki",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'a3f3dc40-1fde-0131-31d5-000c2944c108',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Munki',
    'PayloadContent' => [{
      'PayloadType' => 'ManagedInstalls',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.munki",
      'PayloadUUID' => '7059fe60-222f-0131-31db-000c2944c108',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => 'Munki',
    }],
  }
  munki_prefs.each do |k, v|
    munki_profile['PayloadContent'][0][k] = v
  end
  node.default['cpe_profiles']["#{prefix}.munki"] = munki_profile
end

