# Cookbook Name:: cpe_powermanagement
# Resource:: cpe_powermanagement
#
# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :cpe_powermanagement
provides :cpe_powermanagement, :os => 'darwin'
default_action :config

action :config do
  pw_prefs = node['cpe_powermanagement'].reject { |_k, v| v.nil? }
  if pw_prefs.empty?
    Chef::Log.debug("#{cookbook_name}: No prefs found.")
    return
  end

  # Is this a portable or desktop?
  model = node['hardware']['machine_model'].to_s
  machine_type = model.downcase.include?('book') ? 'portable' : 'desktop'
  # Set the basic identifier
  ident = "com.apple.EnergySaver.#{machine_type}"

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  energy_profile = {
    'PayloadIdentifier'        => "#{prefix}.powermanagement",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope'             => 'System',
    'PayloadType'              => 'Configuration',
    'PayloadUUID'              => 'd1207590-f93a-0133-92e4-4cc760f34b36',
    'PayloadOrganization'      => organization,
    'PayloadVersion'           => 1,
    'PayloadDisplayName'       => 'Power Management',
    'PayloadContent'           => [
      {
        'PayloadType' => 'com.apple.MCX',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.powermanagement",
        'PayloadUUID' => '1a943760-0593-0134-92e6-4cc760f34b36',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Energy Saver',
      },
    ],
  }

  pm_prefs = {
    'ACPower' =>
      node['cpe_powermanagement']['ACPower'].reject { |_k, v| v.nil? },
    'Battery' =>
      node['cpe_powermanagement']['Battery'].reject { |_k, v| v.nil? },
  }

  # Apply all settings to the profile - AC and/or Battery
  pm_prefs.keys.each do |type|
    next if pm_prefs[type].empty?
    energy_profile['PayloadContent'][0]["#{ident}.#{type}-ProfileNumber"] = -1
    energy_profile['PayloadContent'][0]["#{ident}.#{type}"] = pm_prefs[type]
    node.default['cpe_profiles']["#{prefix}.powermanagement"] = energy_profile
  end
end
