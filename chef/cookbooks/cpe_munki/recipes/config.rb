#
# Cookbook Name:: cpe_munki
# Recipe:: munki_config
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

# Set Munki Preferences
ruby_block 'munki_prefs' do
  block do
    local = node['cpe_munki']['local']
    unless local['managed_installs'].empty? && local['managed_uninstalls'].empty?
      node.default['cpe_munki']['preferences']['LocalOnlyManifest'] = 'extra_packages'
    end
    organization = node['organization'] ? node['organization'] : 'Facebook'
    prefix = node['cpe_profiles']['prefix']
    node.default['cpe_profiles']["#{prefix}.munki"] = {
      'PayloadIdentifier'        => "#{prefix}.munki",
      'PayloadRemovalDisallowed' => true,
      'PayloadScope'             => 'System',
      'PayloadType'              => 'Configuration',
      'PayloadUUID'              => 'a3f3dc40-1fde-0131-31d5-000c2944c108',
      'PayloadOrganization'      => organization,
      'PayloadVersion'           => 1,
      'PayloadDisplayName'       => 'Munki',
      'PayloadContent'           => [
        {
          'PayloadType'        => 'com.apple.ManagedClient.preferences',
          'PayloadVersion'     => 1,
          'PayloadIdentifier'  => "#{prefix}.munki",
          'PayloadUUID'        => '7059fe60-222f-0131-31db-000c2944c108',
          'PayloadEnabled'     => true,
          'PayloadDisplayName' => 'Munki',
          'PayloadContent'     => {
            'ManagedInstalls' => {
              'Forced' => [
                {
                  'mcx_preference_settings' => node['cpe_munki']['preferences']
                }
              ]
            }
          }
        }
      ]
    }
  end
  action :run
end
