#
# Cookbook Name:: cpe_bluetooth
# Recipes:: default
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

pp_prefs = {}

ruby_block 'pp_prefs' do
  block do
    pp_prefs = node['cpe_preference_panes'].reject { |_k, v| v.nil? }
    unless pp_prefs.empty?
      organization = node['organization'] ? node['organization'] : 'Facebook'
      prefix = node['cpe_profiles']['prefix']
      node.default['cpe_profiles']["#{prefix}.systempreferences"] = {
        'PayloadIdentifier' => "#{prefix}.systempreferences",
        'PayloadRemovalDisallowed' => true,
        'PayloadScope' => 'System',
        'PayloadType' => 'Configuration',
        'PayloadUUID' => 'f5dae4c4-48eb-4c28-807b-c7b374bbbbd5',
        'PayloadOrganization' => organization,
        'PayloadVersion' => 1,
        'PayloadDisplayName' => 'PreferencePanes',
        'PayloadContent' => [
          {
            'PayloadType' => 'com.apple.ManagedClient.preferences',
            'PayloadVersion' => 1,
            'PayloadIdentifier' => "#{prefix}.systempreferences",
            'PayloadUUID' => '73988076-c873-45cf-9e38-cd98e46365b2',
            'PayloadEnabled' => true,
            'PayloadDisplayName' => 'Blacklist',
            'PayloadContent' => {
              'com.apple.systempreferences' => {
                'Forced' => [
                  {
                    'mcx_preference_settings' => pp_prefs
                  }
                ]
              }
            }
          }
        ]
      }
    end
  end
  action :run
end
