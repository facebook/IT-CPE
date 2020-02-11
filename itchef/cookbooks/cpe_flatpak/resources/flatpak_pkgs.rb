# Cookbook Name:: cpe_flatpak
# Resources:: cpe_flatpak_pkg
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
