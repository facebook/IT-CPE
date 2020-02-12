# Cookbook Name:: cpe_flatpak
# Resources:: cpe_flatpak_pkg
#
# Copyright (c) 2018 Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
resource_name :cpe_flatpak_pkg
provides :cpe_flatpak_pkg, :os => 'linux'
default_action :install
property :pkg, String
property :pfp, String, :name_property => true
property :repo_name, String

load_current_value do |new_resource|
  extend ::CPE::Flatpak
  p = ''
  action_is_remove = new_resource.action.include?(:remove)
  pkg_is_installed = pkg_installed?(new_resource.pkg)
  # If the pkg is installed, do nothing.
  # Do not try to remove a pkg that wasn't installed.
  if pkg_is_installed || (!pkg_is_installed && action_is_remove)
    p = new_resource.pkg
  end
  # If the pkg is installed and we're set to remove, remove it.
  if pkg_is_installed && action_is_remove
    p = 'Delete me!'
  end
  pkg p
end

action :install do
  converge_if_changed :pkg do
    execute "install package #{new_resource.repo_name} #{new_resource.pkg}" do
      command flatpak_install(new_resource.repo_name, new_resource.pkg)
    end
  end
end

action :remove do
  converge_if_changed :pkg do
    execute "remote package #{new_resource.pkg}" do
      command flatpak_remove(new_resource.pkg)
    end
  end
end

action_class do
  include CPE::Flatpak
end
