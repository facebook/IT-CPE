# Cookbook Name:: cpe_flatpak
# Resources:: cpe_flatpak_repo
#
# Copyright (c) 2018 Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
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
