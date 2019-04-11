#
# Cookbook Name:: cpe_powermanagement
# Resource:: cpe_powermanagement
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

resource_name :cpe_powermanagement
default_action :config

# rubocop:disable Metrics/BlockLength
action :config do
  # Does the node have a battery?
  machine_type = node.attr_lookup(
    'hardware/battery', :default => []
  ).empty? ? 'desktop' : 'portable'
  pm_prefs = {
    'ACPower' => {},
    'Battery' => {},
  }

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  energy_profile = {
    'PayloadIdentifier'        => "#{prefix}.powermanagement",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope'             => 'System',
    'PayloadType'              => 'Configuration',
    'PayloadUUID'              => 'd1207590-f93a-0133-92e4-4cc760f34b36',
    'PayloadOrganization'      => organization,
    'PayloadVersion'           => 1,
    'PayloadDisplayName'       => 'Power Management',
    'PayloadContent'           => [
      {
        'PayloadType' => 'com.apple.MCX',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.powermanagement",
        'PayloadUUID' => '1a943760-0593-0134-92e6-4cc760f34b36',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Energy Saver',
      },
    ],
  }

  pm_prefs = {
    'ACPower' =>
      node['cpe_powermanagement']['ACPower'].reject { |_k, v| v.nil? },
    'Battery' =>
      node['cpe_powermanagement']['Battery'].reject { |_k, v| v.nil? },
  }

  # Set the basic identifier
  ident = "com.apple.EnergySaver.#{machine_type}"
  # Apply all settings to the profile - AC and/or Battery
  pm_prefs.each_key do |type|
    next if pm_prefs[type].empty?
    energy_profile['PayloadContent'][0]["#{ident}.#{type}-ProfileNumber"] = -1
    energy_profile['PayloadContent'][0]["#{ident}.#{type}"] = pm_prefs[type]
    node.default['cpe_profiles']["#{prefix}.powermanagement"] = energy_profile
  end
end
# rubocop: enable Metrics/BlockLength
