#
# Cookbook Name:: cpe_chrome
# Attributes:: default
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

# Google Chrome & Chrome Canary attributes
# See https://www.chromium.org/administrators/policy-list-3

default['cpe_chrome'] = {
  'validate_installed' => false,
  'install_package' => false,
  'manage_repo' => false,
  'profile' => {
    'AutoplayWhitelist' => [],
    'ExtensionInstallForcelist' => [],
    'ExtensionInstallBlacklist' => [],
    'EnabledPlugins' => [],
    'DisabledPlugins' => [],
    'DefaultPluginsSetting' => nil,
    'ExtensionInstallSources' => [],
    'PluginsAllowedForUrls' => [],
    'RelaunchNotification' => nil,
    'RelaunchNotificationPeriod' => nil,
  },
  'mp' => {
    'UseMasterPreferencesFile' => false,
    'FileContents' => {},
  },
  'canary_ignored_prefs' => [],
}
