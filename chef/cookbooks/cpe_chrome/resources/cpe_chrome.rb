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
    chrome_prefs = node['cpe_chrome']['profile'].reject { |_k, v| v.nil? }
    if chrome_prefs.empty?
      Chef::Log.info("#{cookbook_name}: No prefs found.")
      return
    end

    prefix = node['cpe_profiles']['prefix']
    organization = node['organization'] ? node['organization'] : 'Facebook'
    chrome_profile = {
      'PayloadIdentifier' => "#{prefix}.browsers.chrome",
      'PayloadRemovalDisallowed' => true,
      'PayloadScope' => 'System',
      'PayloadType' => 'Configuration',
      'PayloadUUID' => 'bf900530-2306-0131-32e2-000c2944c108',
      'PayloadOrganization' => organization,
      'PayloadVersion' => 1,
      'PayloadDisplayName' => 'Chrome',
      'PayloadContent' => [],
    }
    unless chrome_prefs.empty?
      chrome_profile['PayloadContent'].push(
        'PayloadType' => 'com.google.Chrome',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.browsers.chrome",
        'PayloadUUID' => '3377ead0-2310-0131-32ec-000c2944c108',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Chrome',
      )
      chrome_prefs.keys.each do |key|
        next if chrome_prefs[key].nil?
        chrome_profile['PayloadContent'][0][key] = chrome_prefs[key]
      end
    end

    node.default['cpe_profiles']["#{prefix}.browsers.chrome"] = chrome_profile

    # Check for Chrome Canary
    if node.installed?('com.google.Chrome.canary')
      chrome_prefs = node['cpe_chrome']['profile'].reject { |_k, v| v.nil? }
      if chrome_prefs.empty?
        Chef::Log.info("#{cookbook_name}: No prefs found.")
        return
      end

      prefix = node['cpe_profiles']['prefix']
      organization = node['organization'] ? node['organization'] : 'Facebook'
      canary_profile = {
        'PayloadIdentifier' => "#{prefix}.browsers.chromecanary",
        'PayloadRemovalDisallowed' => true,
        'PayloadScope' => 'System',
        'PayloadType' => 'Configuration',
        'PayloadUUID' => 'bf900530-2306-0131-32e2-000c2944c108',
        'PayloadOrganization' => organization,
        'PayloadVersion' => 1,
        'PayloadDisplayName' => 'Chrome Canary',
        'PayloadContent' => [],
      }
      unless chrome_prefs.empty?
        canary_profile['PayloadContent'].push(
          'PayloadType' => 'com.google.Chrome.canary',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => "#{prefix}.browsers.chromecanary",
          'PayloadUUID' => 'bf900530-2306-0131-32e2-000c2944c108',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'Chrome Canary',
        )
        chrome_prefs.keys.each do |key|
          next if chrome_prefs[key].nil?
          canary_profile['PayloadContent'][0][key] = chrome_prefs[key]
        end
      end

      node.default['cpe_profiles']["#{prefix}.browsers.chromecanary"] =
        canary_profile
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
