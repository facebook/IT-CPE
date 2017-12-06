#
# Cookbook Name:: cpe_adobe_flash
# Resource:: cpe_adobe_flash_darwin
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

resource_name :cpe_adobe_flash_darwin
default_action :config
provides :cpe_adobe_flash, :os => 'darwin'

action_class do
  def configure
    return unless node['cpe_adobe_flash']['configure']

    configs = node['cpe_adobe_flash']['configs'].reject { |_k, v| v.nil? }
    node.default['cpe_adobe_flash']['_applied_configs'] = configs

    launchd 'com.adobe.fpsaud' do
      only_if { ::File.exist?('/Library/LaunchDaemons/com.adobe.fpsaud.plist') }
      action :nothing
    end

    directory config_dir do
      not_if { configs.empty? }
      owner 'root'
      group 'admin'
      mode 0755
      action :create
    end
    template ::File.join(config_dir, 'mms.cfg') do # ~ FB016
      source 'cpe_adobe_flash.erb'
      owner 'root'
      group 'admin'
      mode 0644
      action configs.empty? ? :delete : :create
      notifies :restart, 'launchd[com.adobe.fpsaud]'
    end
  end

  def uninstall
    return unless node['cpe_adobe_flash']['uninstall']

    node.default['cpe_munki']['local']['managed_uninstalls'] <<
      'AdobeFlashPlayer'

    home_dir = node.attr_lookup('cpe/person/home_dir')
    return unless home_dir
    internet_plugins = '/Library/Internet Plug-Ins'
    user_internet_plugins = ::File.join(home_dir, 'Library/Internet Plug-Ins')
    flash_player_installer =
      '/Library/Application Support/Adobe/Flash Player Install Manager'

    [
      ::File.join(internet_plugins, 'Flash Player.plugin'),
      ::File.join(internet_plugins, 'PepperFlashPlayer'),
      ::File.join(user_internet_plugins, 'Flash Player.plugin'),
      ::File.join(user_internet_plugins, 'Flash Player Enabler.plugin'),
      ::File.join(user_internet_plugins, 'PepperFlashPlayer'),
      '/Library/PreferencePanes/Flash Player.prefPane',
      config_dir,
    ].each do |dirpath|
      directory dirpath do
        recursive true
        action :delete
      end
    end

    [
      ::File.join(internet_plugins, 'flashplayer.xpt'),
      ::File.join(internet_plugins, 'Shockwave Flash NP-PPC'),
      ::File.join(user_internet_plugins, 'flashplayer.xpt'),
      ::File.join(user_internet_plugins, 'Shockwave Flash NP-PPC'),
      ::File.join(flash_player_installer, 'FPSAUConfig.xml'),
      ::File.join(flash_player_installer, 'fpsaud'),
    ].each do |fpath|
      file fpath do
        action :delete
      end
    end

    launchd 'com.adobe.fpsaud' do
      action :delete
    end
  end

  def config_dir
    '/Library/Application Support/Macromedia'
  end
end

action :config do
  configure
  uninstall
end
