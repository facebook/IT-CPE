#
# Cookbook Name:: cpe_adobe_flash
# Resource:: cpe_adobe_flash_windows
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_adobe_flash_windows
default_action :config
provides :cpe_adobe_flash, :os => 'windows'

action_class do
  def configure
    return unless node['cpe_adobe_flash']['configure']

    configs = node['cpe_adobe_flash']['configs'].reject { |_k, v| v.nil? }
    node.default['cpe_adobe_flash']['_applied_configs'] = configs

    template ::File.join(config_dir, 'mms.cfg') do
      source 'cpe_adobe_flash.erb'
      rights :read, 'Everyone'
      rights :full_control, ['Administrators', 'SYSTEM']
      action configs.empty? ? :delete : :create
    end
  end

  def uninstall
    return unless node['cpe_adobe_flash']['uninstall']

    node.default['cpe_choco']['uninstall']['flashplayerplugin'] = {
      'version' => 'any',
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
