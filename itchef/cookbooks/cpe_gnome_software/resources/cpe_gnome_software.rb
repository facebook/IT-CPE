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

# Cookbook Name:: cpe_gnome_software
# Resource:: cpe_gnome_software

resource_name :cpe_gnome_software
provides :cpe_gnome_software
default_action :manage

action :manage do
  unless node.fedora?
    fail 'cpe_gnome_software is only supported on Fedora'
  end

  return unless node['cpe_gnome_software']['manage']

  manage_gnome_software
  manage_packagekit
end

action_class do
  def manage_gnome_software
    return unless node['cpe_gnome_software']['gnome_software']['manage']

    node.default['cpe_dconf']['settings']['00-gnome_software'] = {
      'org/gnome/software' =>
        node['cpe_gnome_software']['gnome_software'].reject do |k, _|
          k == 'manage'
        end,
    }
  end

  def manage_packagekit
    return unless node['cpe_gnome_software']['packagekit']['manage']

    action = node['cpe_gnome_software']['packagekit']['enable'] ?
      :unmask : :mask

    %w{
      packagekit
      packagekit-offline-update
    }.each do |unit|
      systemd_unit "#{unit}.service" do
        only_if { node.rpm_installed?('PackageKit') }
        action action
      end
    end
  end
end
