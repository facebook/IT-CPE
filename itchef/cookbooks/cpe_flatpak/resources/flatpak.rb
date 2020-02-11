# Cookbook Name:: cpe_flatpak
# Resources:: cpe_flatpak
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

resource_name :cpe_flatpak_linux
provides :cpe_flatpak, :os => 'linux'
default_action :manage
property :fp, String, :name_property => true

action :manage do
  return unless node['cpe_flatpak']['manage']

  ign_failure = node['cpe_flatpak']['ignore_failure']

  #  Keep Flatpak up to date
  package 'flatpak' do # ~FB012
    action :upgrade
  end

  #  Remove any packages that have been removed from the recipe
  delta = (flatpak_packages_receipt - node['cpe_flatpak']['pkgs'].to_h.keys)
  delta.each do |p|
    cpe_flatpak_pkg p do
      pkg p
      action :remove
      ignore_failure ign_failure
    end
  end

  #  Remove any remotes that have been removed from the recipe.
  delta = (flatpak_remotes_receipt - node['cpe_flatpak']['remotes'].to_h.keys)
  delta.each do |r|
    cpe_flatpak_repo r do
      repo_name r
      action :remove
      ignore_failure ign_failure
    end
  end

  #  Install any new remotes
  node['cpe_flatpak']['remotes'].each do |r, u|
    cpe_flatpak_repo r do
      repo_name r
      url u
      ignore_failure ign_failure
    end
  end

  #  Install any new packages
  node['cpe_flatpak']['pkgs'].each do |p, r|
    cpe_flatpak_pkg p do
      pkg p
      repo_name r
      ignore_failure ign_failure
    end
  end

  cache_dir = "#{chef_cache}/cpe_flatpak"
  directory cache_dir do
    mode 0755
    owner 'root'
    group 'root'
  end

  rem = node['cpe_flatpak']['remotes'].keys
  #  Keep track of what remotes are installed for idempotency.
  file flatpak_remotes_receipt_path do
    content Chef::JSONCompat.to_json_pretty(rem)
    mode '644'
    owner 'root'
    group 'root'
    action :create
  end

  packages = node['cpe_flatpak']['pkgs'].keys
  #  Keep track of what packages are installed for idempotency.
  file flatpak_packages_receipt_path do
    content Chef::JSONCompat.to_json_pretty(packages)
    mode '644'
    owner 'root'
    group 'root'
    action :create
  end
end

action_class do
  include CPE::Flatpak
end
