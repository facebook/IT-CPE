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

# Cookbook Name:: cpe_browsers
# Spec:: windows_chrome_setting

require 'json'
require_relative '../libraries/windows_chrome_settingv2'
require_relative '../libraries/gen_windows_chrome_known_settings'
require_relative '../libraries/chrome_windows'

RSpec.describe WindowsChromeSettingV2 do
  JSON_EXAMPLE_DATA = [
    {
      :toplevel_name => 'My managed bookmarks folder',
    },
    {
      :url => 'google.com',
      :name => 'Google',
    },
    {
      :url => 'youtube.com',
      :name => 'Youtube',
    },
    {
      :name => 'Chrome links',
      :children => [
        {
          :url => 'chromium.org',
          :name => 'Chromium',
        },
        {
          :url => 'dev.chromium.org',
          :name => 'Chromium Developers',
        },
      ],
    },
  ].freeze

  settings = {
    'ManagedBookmarks' => {
      'registry_location' =>
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome',
      'subkey' => 'ManagedBookmarks',
      'type' => :string,
      'iterable' => false,
      'input_value' => JSON_EXAMPLE_DATA,
      'output' => [{
        :name => 'ManagedBookmarks',
        :type => :string,
        :data => JSON_EXAMPLE_DATA.to_json,
      }],
    },
    'DefaultPluginsSetting' => {
      'registry_location' =>
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome',
      'subkey' => 'DefaultPluginsSetting',
      'type' => :dword,
      'iterable' => false,
      'input_value' => 3,
      'output' => [{
        :name => 'DefaultPluginsSetting',
        :type => :dword,
        :data => 3,
      }],
    },
    'PluginsAllowedForUrls' => {
      'registry_location' =>
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome\PluginsAllowedForUrls',
      'subkey' => 'PluginsAllowedForUrls',
      'type' => :string,
      'iterable' => true,
      'input_value' => ['[*.]facebook.com', '[*.]fb.com'],
      'output' => [
        {
          :data => '[*.]facebook.com',
          :name => '1',
          :type => :string,
        },
        {
          :data => '[*.]fb.com',
          :name => '2',
          :type => :string,
        },
      ],
    },
    'SitePerProcess' => {
      'registry_location' =>
        'HKEY_LOCAL_MACHINE\Software\Policies\Google\Chrome',
      'subkey' => 'SitePerProcess',
      'type' => :dword,
      'iterable' => false,
      'input_value' => true,
      'output' => [{
        :name => 'SitePerProcess',
        :type => :dword,
        :data => 1,
      }],
    },
  }

  settings.each_key do |setting|
    setting_values =
      CPE::ChromeManagement::KnownSettings::GENERATED.fetch(setting, nil)
    setting_values.value = settings[setting]['input_value']
    context 'registry location should equal' do
      subject { setting_values.registry_location }
      it { should eql settings[setting]['registry_location'] }
    end
    context 'chef_to_reg_provider data output should equal' do
      subject { setting_values.to_chef_reg_provider }
      it { should eql settings[setting]['output'] }
    end
  end
end
