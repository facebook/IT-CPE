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

# Cookbook Name:: cpe_bluetooth
# Resource:: cpe_bluetooth

resource_name :cpe_bluetooth
provides :cpe_bluetooth, :os => 'darwin'
default_action :config

action :config do
  prefs = node['cpe_bluetooth'].reject { |_k, v| v.nil? }
  if prefs.empty?
    Chef::Log.info("#{cookbook_name}: No prefs found.")
    return
  end

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'

  profile = {
    'PayloadIdentifier' => "#{prefix}.bluetooth",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => '2E33AB8C-AFF6-4BA7-8110-412EC841423E',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Bluetooth',
    'PayloadContent' => [{
      'PayloadType' => 'com.apple.Bluetooth',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.bluetooth",
      'PayloadUUID' => '37F77492-E026-423F-8F7B-567CC06A7585',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => 'Bluetooth',
    }],
  }
  prefs.each do |k, v|
    profile['PayloadContent'][0][k] = v
  end
  node.default['cpe_profiles']["#{prefix}.bluetooth"] = profile
end
