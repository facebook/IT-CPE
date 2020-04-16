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

# Cookbook Name:: cpe_preferencepanes
# Resource:: default

resource_name :cpe_preferencepanes
provides :cpe_preferencepanes, :os => 'darwin'
default_action :config

# rubocop:disable Metrics/BlockLength
action :config do
  prefs = node['cpe_preferencepanes'].reject { |_k, v| v.nil? }
  return if prefs.empty?
  prefix = node['cpe_profiles']['prefix']
  organization = node['organization'] ? node['organization'] : 'Facebook'
  pane_profile = {
    'PayloadIdentifier' => "#{prefix}.prefpanes",
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => 'E2R9I0K4-1C7F-4662-9921-GCE3RBK7E4BD',
    'PayloadOrganization' => organization,
    'PayloadVersion' => 1,
    'PayloadDisplayName' => 'Preference Panes',
    'PayloadContent' => [
      {
        'PayloadType' => 'com.apple.systempreferences',
        'PayloadVersion' => 1,
        'PayloadIdentifier' => "#{prefix}.prefpanes",
        'PayloadUUID' => '77537A7B-76E2-4ED8-B559-A581002CFD3C',
        'PayloadEnabled' => true,
        'PayloadDisplayName' => 'Preference Panes',
      },
    ],
  }
  prefs.each do |k, v|
    pane_profile['PayloadContent'][0][k] = v
  end
  node.default['cpe_profiles']["#{prefix}.prefpanes"] = pane_profile
end
# rubocop: enable Metrics/BlockLength
