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
# Resource:: cpe_munki_config

resource_name :cpe_munki_config
provides :cpe_munki_config, :os => 'darwin'
default_action :config

action :config do
  return unless node['cpe_munki']['configure']

  munki_prefs = node['cpe_munki']['preferences'].reject { |_k, v| v.nil? }
  if munki_prefs.empty?
    Chef::Log.info("#{cookbook_name}: No prefs found.")
    return
  end

  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'

  munki_profile = {
    'PayloadIdentifier' => "#{prefix}.munki",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'a3f3dc40-1fde-0131-31d5-000c2944c108',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Munki',
    'PayloadContent' => [{
      'PayloadType' => 'ManagedInstalls',
      'PayloadVersion' => 1,
      'PayloadIdentifier' => "#{prefix}.munki",
      'PayloadUUID' => '7059fe60-222f-0131-31db-000c2944c108',
      'PayloadEnabled' => true,
      'PayloadDisplayName' => 'Munki',
    }],
  }
  munki_prefs.each do |k, v|
    munki_profile['PayloadContent'][0][k] = v
  end
  node.default['cpe_profiles']["#{prefix}.munki"] = munki_profile
end
