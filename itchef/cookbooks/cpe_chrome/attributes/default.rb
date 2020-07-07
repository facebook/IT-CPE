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

# Cookbook Name:: cpe_chrome
# Attributes:: default

# Google Chrome & Chrome Canary attributes
# See https://cloud.google.com/docs/chrome-enterprise/policies

default['cpe_chrome'] = {
  'validate_installed' => false,
  'install_package' => false,
  'manage_repo' => false,
  'extension_profile' => {
    # '1234567890qwertyuiop' => {
    #   'display_name' => 'Example Extension',
    #   'payload_uuid' => '9D359A7A-EF21-4D02-8186-001974CEB796',
    #   'profile_uuid' => 'EAA802D2-D139-474A-87CE-1DEEDCCECBAE',
    #   'profile' => {
    #     'KeyName' => {
    #       'windows_value_type' => :string,
    #       'value' => 'some_string',
    #     },
    #   },
    # },
  },
  'profile' => {
    'AutoplayWhitelist' => [],
    'ExtensionInstallForcelist' => [],
    'ExtensionInstallBlacklist' => [],
    'DefaultPluginsSetting' => nil,
    'ExtensionInstallSources' => [],
    'PluginsAllowedForUrls' => [],
    'RelaunchNotification' => nil,
    'RelaunchNotificationPeriod' => nil,
    'TotalMemoryLimitMb' => nil,
  },
  'mp' => {
    'UseMasterPreferencesFile' => false,
    'FileContents' => {},
  },
  'canary_ignored_prefs' => [],
  '_use_new_windows_provider' => false,
}
