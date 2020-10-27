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

# Cookbook Name:: cpe_munki
# Resource:: cpe_munki_defaults_config

provides :cpe_munki_defaults_config, :os => 'darwin'
default_action :config

action :config do
  return unless node['cpe_munki']['configure']

  munki_prefs = node['cpe_munki'][
    'defaults_preferences'].reject { |_k, v| v.nil? }

  if munki_prefs.empty?
    Chef::Log.info("#{cookbook_name}: No defaults prefs found.")
    return
  end

  munki_prefs.each do |pref, value|
    # Keys should not exist in both namespaces
    if node['cpe_munki']['preferences'].key?(pref)
      fail <<-REASON
        The preference #{pref} is configured both in
        node['cpe_munki']['preferences' and
        node['cpe_munki']['defaults_preferences']. Please choose
        one method to configure this preference
      REASON
    end

    macos_userdefaults pref do
      domain '/Library/Preferences/ManagedInstalls'
      key pref
      value value
      action :write
    end
  end
end
