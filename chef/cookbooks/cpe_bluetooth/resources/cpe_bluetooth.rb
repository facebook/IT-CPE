#
# Cookbook Name:: cpe_bluetooth
# Resource:: cpe_bluetooth
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

resource_name :cpe_bluetooth
default_action :config

action :config do
  prefs = node['cpe_bluetooth'].reject { |_k, v| v.nil? }
  return if prefs.empty?
  organization = node['organization'] || 'Facebook'
  prefix = node['cpe_profiles']['prefix']
  node.default['cpe_profiles']["#{prefix}.bluetooth"] = {
    'PayloadIdentifier' => "#{prefix}.bluetooth",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => '2E33AB8C-AFF6-4BA7-8110-412EC841423E',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Bluetooth',
    'PayloadContent' => [
      {
        'PayloadType' => 'com.apple.ManagedClient.preferences',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.bluetooth",
        'PayloadUUID' => '37F77492-E026-423F-8F7B-567CC06A7585',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Bluetooth',
        'PayloadContent' => {
          'com.apple.Bluetooth' => {
            'Forced' => [
              {
                'mcx_preference_settings' => prefs,
              },
            ],
          },
        },
      },
    ],
  }
end
