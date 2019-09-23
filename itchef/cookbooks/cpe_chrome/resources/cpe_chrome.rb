#
# Cookbook Name:: cpe_chrome
# Resources:: cpe_chrome
#
# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :cpe_chrome
default_action :config

action :config do
  install_repos
  install_chrome
  manage_chrome
end

action_class do
  def install_repos
    return unless node.linux?
    return unless node['cpe_chrome']['manage_repo']

    yum_repository 'google-chrome' do
      only_if { node.fedora? }
      description 'Google Chrome repo'
      baseurl 'http://dl.google.com/linux/chrome/rpm/stable/x86_64'
      enabled true
      gpgkey 'https://dl.google.com/linux/linux_signing_key.pub'
      gpgcheck true
      action :create
    end

    apt_repository 'google-chrome' do
      only_if { node.debian_family? }
      uri 'http://dl.google.com/linux/chrome/deb/'
      distribution 'stable'
      components ['main']
      arch 'amd64'
      key 'EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796'
      action :add
    end
  end

  def install_chrome
    return unless node.linux?
    return unless node['cpe_chrome']['install_package']

    package 'google-chrome-stable' do
      only_if { node.fedora? || node.debian_family? }
      action :upgrade
    end
  end

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
      manage_chrome_macos(mprefs, prefs)
    when 'linux'
      manage_chrome_linux(mprefs, prefs)
    end
  end

  def manage_chrome_linux(mprefs, prefs)
    # Chromium and Chrome get the same preferences
    %w{
      /etc/opt
      /etc/opt/chrome
      /etc/opt/chrome/policies
      /etc/opt/chrome/policies/managed
      /etc/opt/chrome/policies/recommended
    }.each do |path|
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

  def manage_chrome_macos(mprefs, prefs)
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
      'PayloadContent' => [{
        'PayloadType' => 'com.google.Chrome',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.browsers.chrome",
        'PayloadUUID' => '3377ead0-2310-0131-32ec-000c2944c108',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Chrome',
      }],
    }
    prefs.each do |k, v|
      chrome_profile['PayloadContent'][0][k] = v
    end
    profile_domain = "#{node['cpe_profiles']['prefix']}.browsers.chrome"
    node.default['cpe_profiles'][profile_domain] = chrome_profile

    # Check for Chrome Canary
    if node.installed?('com.google.Chrome.canary')
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
        'PayloadContent' => [{
          'PayloadType' => 'com.google.Chrome.canary',
          'PayloadVersion' => 1,
          'PayloadIdentifier' => "#{prefix}.browsers.chromecanary",
          'PayloadUUID' => 'bf900530-2306-0131-32e2-000c2944c108',
          'PayloadEnabled' => true,
          'PayloadDisplayName' => 'Chrome Canary',
        }],
      }
      prefs.each do |k, v|
        canary_profile['PayloadContent'][0][k] = v
      end
      profile_domain = "#{node['cpe_profiles']['prefix']}.browsers.chromecanary"
      node.default['cpe_profiles'][profile_domain] = canary_profile
    end
    # Apply the Master Preferences file
    master_path = '/Library/Google/Google Chrome Master Preferences'
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
