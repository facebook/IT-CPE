# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_safari
# Resources:: cpe_safari
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_safari
default_action :config

action :config do
  safari_prefs = node['cpe_safari'].reject { |_k, v| v.nil? }
  return if safari_prefs.empty?
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] || 'Facebook'
  node.default['cpe_profiles']["#{prefix}.browsers.safari"] = {
    'PayloadIdentifier'        => "#{prefix}.browsers.safari",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope'             => 'System',
    'PayloadType'              => 'Configuration',
    'PayloadUUID'              => 'bf900530-2306-0131-32e2-000c2944c108',
    'PayloadOrganization'      => organization,
    'PayloadVersion'           => 1,
    'PayloadDisplayName'       => 'Safari',
    'PayloadContent'           => [
      {
        'PayloadType'        => 'com.apple.ManagedClient.preferences',
        'PayloadVersion'     => 1,
        'PayloadIdentifier'  => "#{prefix}.browsers.safari",
        'PayloadUUID'        => '3377ead0-2310-0131-32ec-000c2944c108',
        'PayloadEnabled'     => true,
        'PayloadDisplayName' => 'Safari',
        'PayloadContent'     => {
          'com.apple.Safari' => {
            'Forced' => [
              {
                'mcx_preference_settings' => safari_prefs,
              },
            ],
          },
        },
      },
    ],
  }
end
