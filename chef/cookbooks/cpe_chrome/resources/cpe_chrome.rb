# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_chrome
# Resources:: cpe_chrome
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_chrome
default_action :config

action :config do
  manage_chrome
end

# rubocop:disable Metrics/BlockLength
action_class do
  def manage_chrome
    case node['platform_family']
    when 'mac_os_x'
      manage_chrome_osx
    end
  end

  def manage_chrome_osx
    prefs = node['cpe_chrome']['profile'].reject { |_k, v| v.nil? }
    return if prefs.empty?
    prefix = node['cpe_profiles']['prefix']
    organization = node['organization'] ? node['organization'] : 'Facebook'
    node.default['cpe_profiles']["#{prefix}.browsers.chrome"] = {
      'PayloadIdentifier'        => "#{prefix}.browsers.chrome",
      'PayloadRemovalDisallowed' => true,
      'PayloadScope'             => 'System',
      'PayloadType'              => 'Configuration',
      'PayloadUUID'              => 'bf900530-2306-0131-32e2-000c2944c108',
      'PayloadOrganization'      => organization,
      'PayloadVersion'           => 1,
      'PayloadDisplayName'       => 'Chrome',
      'PayloadContent'           => [
        {
          'PayloadType'        => 'com.apple.ManagedClient.preferences',
          'PayloadVersion'     => 1,
          'PayloadIdentifier'  => "#{prefix}.browsers.chrome",
          'PayloadUUID'        => '3377ead0-2310-0131-32ec-000c2944c108',
          'PayloadEnabled'     => true,
          'PayloadDisplayName' => 'Chrome',
          'PayloadContent'     => {
            'com.google.Chrome' => {
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
    # Check for Chrome Canary
    if node.installed?('com.google.Chrome.canary')
      prefix = node['cpe_profiles']['prefix']
      organization = node['organization'] ? node['organization'] : 'Facebook'
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
                    'mcx_preference_settings' => prefs,
                  },
                ],
              },
            },
          },
        ],
      }
    end
    # Apply the Master Preferences file
    unless node['cpe_chrome']['mp']['UseMasterPreferencesFile'] == false
      mprefs =
        node['cpe_chrome']['mp']['FileContents'].reject { |_k, v| v.nil? }
      master_path = value_for_platform_family(
        'mac_os_x' => '/Library/Google/Google Chrome Master Preferences',
        'windows' =>
          'c:\Program Files (x86)\Google\Chrome\Application\master_preferences',
      )
      if mprefs.empty?
        file master_path do
          action :delete
        end
        return
      end
      directory '/Library/Google' do
        mode '0755'
        owner 'root'
        group 'wheel'
        action :create
      end
      # Create the Master Preferences file
      file master_path do
        mode '0644'
        owner 'root'
        group 'wheel'
        action :create
        content Chef::JSONCompat.to_json_pretty(mprefs)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
