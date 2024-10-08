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
# Recipe:: default

return unless node.macos?

cpe_munki_install 'Install Munki'
cpe_munki_local 'Manage Local Munki Manifest'
cpe_munki_defaults_config 'Manage Defaults Preferences'
cpe_munki_config 'Manage Munki Settings'

cookbook_file 'munki_preflight.py' do
  mode '0755'
  owner node.root_user
  group node.root_group
  path '/usr/local/munki/preflight'
  action :create
end
