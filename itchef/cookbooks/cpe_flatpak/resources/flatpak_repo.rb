# Cookbook Name:: cpe_flatpak
# Resources:: cpe_flatpak_repo
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

resource_name :cpe_flatpak_repo
provides :cpe_flatpak_repo, :os => 'linux'
default_action :install
property :repo_name, String
property :rfp, String, :name_property => true
property :url, String, :desired_state => false

load_current_value do |new_resource|
  extend ::CPE::Flatpak
  r = ''
  action_is_remove = new_resource.action.include?(:remove)
  repo_is_installed = repo_installed?(new_resource.repo_name)
  # If the repo is installed, do nothing.
  # Do not try to remove a repo that wasn't installed.
  if repo_is_installed || (!repo_is_installed && action_is_remove)
    r = new_resource.repo_name
  end
  # If the repo is installed and we're set to remove, remove it.
  if repo_is_installed && action_is_remove
    r = 'Delete me!'
  end
  repo_name r
end

action :install do
  converge_if_changed :repo_name do
    execute "create remote #{new_resource.repo_name}" do
      command flatpak_remote_add(new_resource.repo_name, new_resource.url)
    end
  end
end

action :remove do
  converge_if_changed :repo_name do
    execute "remove remote #{new_resource.repo_name}" do
      command flatpak_remote_remove(new_resource.repo_name)
    end
  end
end

action_class do
  include CPE::Flatpak
end
