# Cookbook Name:: cpe_init
# Recipe:: company_init
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

# HERE: This is where you would set attributes that are consumed by the API
# cookbooks.
# Be sure to replace all instances of MYCOMPANY with your actual company name
node.default['organization'] = 'MYCOMPANY'
prefix = "com.#{node['organization']}.chef"
node.default['cpe_launchd']['prefix'] = prefix
node.default['cpe_profiles']['prefix'] = prefix

# Install munki
node.default['cpe_munki']['install'] = false
# Configure munki
node.default['cpe_munki']['configure'] = false
# Override default munki settings
node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
  'https://munki.MYCOMPANY.com/repo'
node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] = true
# Manage Local Munki Manifest
managed_installs = [
  # Put managed install items here
]
managed_installs.each do |item|
  node.default['cpe_munki']['local']['managed_installs'] << item
end
