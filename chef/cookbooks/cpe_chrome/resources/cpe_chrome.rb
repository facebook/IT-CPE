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
    return if node['cpe_chrome']['validate_installed'] &&
      !node.installed?('com.google.Chrome')
    if node['cpe_chrome']['mp']['UseMasterPreferencesFile']
      mprefs =
        node['cpe_chrome']['mp']['FileContents'].reject { |_k, v| v.nil? }
    else
      mprefs = {}
    end
    prefs = node['cpe_chrome']['profile'].reject { |_k, v| v.nil? }
    return if prefs.empty? && mprefs.empty?
    case node['os']
    when 'darwin'
      manage_chrome_osx(mprefs, prefs)
    when 'linux'
      manage_chrome_linux(mprefs, prefs)
    end
  end

  def manage_chrome_linux(mprefs, prefs)
    # Chromium and Chrome get the same preferences
    %w[
      /etc/opt
      /etc/opt/chrome
      /etc/opt/chrome/policies
      /etc/opt/chrome/policies/managed
      /etc/opt/chrome/policies/recommended
    ].each do |path|
      directory path do
        mode '0755'
        owner root_owner
        group root_group
      end
    end
    migrate_chromium_settings_linux
    link '/etc/chromium' do
      to '/etc/opt/chrome'
      owner root_owner
      group root_group
    end
    {
      '/etc/opt/chrome/policies/managed/test_policy.json' => prefs,
      '/etc/opt/chrome/policies/recommended/test_policy.json' => mprefs,
    }.each do |path, preferences|
      if preferences.empty?
        file path do
          action :delete
        end
      else
        file path do
          mode '0644'
          owner root_owner
          group root_group
          action :create
          content Chef::JSONCompat.to_json_pretty(preferences)
        end
      end
    end
  end

  def manage_chrome_osx(mprefs, prefs)
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
              'com.google.Chrome.canary' => {
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
    master_path = value_for_platform_family(
      'mac_os_x' => '/Library/Google/Google Chrome Master Preferences',
      'windows' =>
        'c:\Program Files (x86)\Google\Chrome\Application\master_preferences',
    )
    if mprefs.empty?
      file master_path do
        action :delete
      end
    else
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

  def migrate_chromium_settings_linux
    # if /etc/chromium already exists, chmod + chown everything inside of it
    # and move it to /etc/opt/chrome
    bash 'migrate chromium directory' do
      only_if do
        ::File.directory?('/etc/chromium') &&
        !::File.symlink?('/etc/chromium')
      end
      code <<-EOH
        find /etc/chromium -type d -exec chmod 0755 {} \\;
        find /etc/chromium -type f -exec chmod 0644 {} \\;
        chown -R #{root_owner}:#{root_group} /etc/chromium
        cp -R /etc/chromium/* /etc/opt/chrome/
        rm -rf /etc/chromium
      EOH
    end
  end
end
# rubocop:enable Metrics/BlockLength
