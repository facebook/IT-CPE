# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8

# Cookbook Name:: cpe_crypt
# Resource:: cpe_crypt_install
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#

# rubocop:disable Style/HashSyntax
resource_name :cpe_crypt_install
provides :cpe_crypt_install, :os => 'darwin'
default_action :manage

action_class do
  def install
    pkg = node['cpe_crypt']['pkg']
    # Install Crypt auth plugin
    cpe_remote_pkg 'crypt' do
      version pkg['version']
      checksum pkg['checksum']
      receipt pkg['receipt']
      pkg_name pkg['pkg_name'] if pkg['pkg_name']
      pkg_url pkg['pkg_url'] if pkg['pkg_url']
    end
  end

  def remove
    Chef::Log.info("#{cookbook_name}: Tag found, exempt from Crypt")
    # Remove the plugin and settings
    directory '/Library/Security/SecurityAgentPlugins/Crypt.bundle' do
      recursive true
      action :delete
    end

    pkg = node['cpe_crypt']['pkg']
    # Forget the package
    execute "/usr/sbin/pkgutil --forget #{pkg['receipt']}" do
      not_if do
        shell_out("/usr/sbin/pkgutil --pkg-info #{pkg['receipt']}").error?
      end
      action :run
    end
  end
end

action :manage do
  node['cpe_crypt']['install'] ? install : remove
end
