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

# Cookbook Name:: cpe_adobe_flash
# Resource:: cpe_adobe_flash_windows

resource_name :cpe_adobe_flash_windows
default_action :config
provides :cpe_adobe_flash, :os => 'windows'

action_class do
  def configure
    return unless node['cpe_adobe_flash']['configure']

    configs = node['cpe_adobe_flash']['configs'].reject { |_k, v| v.nil? }
    node.default['cpe_adobe_flash']['_applied_configs'] = configs

    template ::File.join(config_dir, 'mms.cfg') do # ~FB031
      source 'cpe_adobe_flash.erb'
      rights :read, 'Everyone'
      rights :full_control, ['Administrators', 'SYSTEM']
      action configs.empty? ? :delete : :create
    end
  end

  def uninstall
    return unless node['cpe_adobe_flash']['uninstall']

    node.default['cpe_choco']['uninstall']['flashplayerplugin'] = {
      'version' => 'all',
    }

    file ::File.join(config_dir, 'mms.cfg') do
      action :delete
    end
  end

  def config_dir
    # Account for 32 / 64 bit systems in file structure
    architecture = node['kernel']['os_info']['os_architecture']
    dir_modifier = architecture.include?('64-bit') ? 'SysWOW64' : 'System32'
    ::File.join(ENV['windir'], dir_modifier, 'Macromed', 'Flash')
  end
end

action :config do
  configure
  uninstall
end
