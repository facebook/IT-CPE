# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8
# Cookbook Name:: cpe_autopkg
# Resource:: cpe_autopkg_setup
#
# Copyright 2016, Nick McSpadden
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

resource_name :cpe_autopkg_setup
default_action :setup

action :setup do
  return unless node['cpe_autopkg']['setup']
  # Set up AutoPkg
  # Create the home directory
  directory 'autopkg_home' do
    path node['cpe_autopkg']['dir']['home']
    user node['cpe_autopkg']['user']
    mode '0755'
  end

  # Create the service directories
  node['cpe_autopkg']['dir'].values.each do |autopkg_dir|
    directory autopkg_dir do
      user node['cpe_autopkg']['user']
      mode '0755'
    end
  end

  # Set up AutoPkg preferences for 'MUNKI_REPO'
  mac_os_x_userdefaults 'autopkg_munkirepo' do
    domain 'com.github.autopkg'
    user node['cpe_autopkg']['user']
    key 'MUNKI_REPO'
    value node['cpe_autopkg']['munki_repo']
  end

  # Set up AutoPkg preferences for 'RECIPE_REPO_DIR'
  mac_os_x_userdefaults 'autopkg_reciperepodir' do
    domain 'com.github.autopkg'
    user node['cpe_autopkg']['user']
    key 'RECIPE_REPO_DIR'
    value node['cpe_autopkg']['dir']['reciperepos']
  end

  # Set up AutoPkg preferences for 'RECIPE_OVERRIDE_DIRS'
  mac_os_x_userdefaults 'autopkg_recipeoverridedirs' do
    domain 'com.github.autopkg'
    user node['cpe_autopkg']['user']
    key 'RECIPE_OVERRIDE_DIRS'
    value node['cpe_autopkg']['dir']['recipeoverrides']
  end

  # Set up AutoPkg preferences for 'CACHE_DIR'
  mac_os_x_userdefaults 'autopkg_cachedir' do
    domain 'com.github.autopkg'
    user node['cpe_autopkg']['user']
    key 'CACHE_DIR'
    value node['cpe_autopkg']['dir']['cache']
  end

  # Copy the autopkg_overrides into our target overrides directory
  remote_directory 'overrides' do
    path node['cpe_autopkg']['dir']['recipeoverrides']
    source 'autopkg_overrides'
    overwrite true
    mode '0755'
    action :create
  end

  # Create the run list file
  file 'run_list' do
    only_if { node['cpe_autopkg']['run_list'].any? }
    path node['cpe_autopkg']['run_list_file']
    mode '0644'
    user node['cpe_autopkg']['user']
    content Chef::JSONCompat.to_json_pretty(node['cpe_autopkg']['run_list'])
  end

  # Copy over organization's recipes into Recipes dir
  remote_directory 'org_recipes' do
    path node['cpe_autopkg']['dir']['recipes']
    source 'org_recipes'
    mode '0755'
    action :create
  end
end
