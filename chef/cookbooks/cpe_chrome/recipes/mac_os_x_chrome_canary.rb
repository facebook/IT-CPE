#
# Cookbook Name:: cpe_chrome
# Recipe:: mac_os_x_chrome_canary
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

return unless node.installed?('com.google.Chrome.canary')

canary_prefs = {}

ruby_block 'canary_prefs' do
  block do
    canary_prefs = node['cpe_chrome'].reject { |_k, v| v.nil? }
    unless canary_prefs.empty?
      organization = node['organization'] ? node['organization'] : 'Facebook'
      prefix = node['cpe_profiles']['prefix']
      node.default['cpe_profiles']["#{prefix}.browsers.chromecanary"] = {
        'PayloadIdentifier'        => "#{prefix}.browsers.chromecanary",
        'PayloadRemovalDisallowed' => true,
        'PayloadScope'             => 'System',
        'PayloadType'              => 'Configuration',
        'PayloadUUID'              => 'bf900530-2306-0131-32e2-000c2944c108',
        'PayloadOrganization'      => organization,
        'PayloadVersion'           => 1,
        'PayloadDisplayName'       => 'Chrome Canary',
        'PayloadContent'           => [
          {
            'PayloadType'        => 'com.apple.ManagedClient.preferences',
            'PayloadVersion'     => 1,
            'PayloadIdentifier'  => "#{prefix}.browsers.chromecanary",
            'PayloadUUID'        => '3377ead0-2310-0131-32ec-000c2944c108',
            'PayloadEnabled'     => true,
            'PayloadDisplayName' => 'Chrome Canary',
            'PayloadContent'     => {
              'com.apple.Safari' => {
                'Forced' => [
                  {
                    'mcx_preference_settings' => canary_prefs,
                  },
                ],
              },
            },
          },
        ],
      }
    end
  end
  action :run
end
