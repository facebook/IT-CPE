#
# Cookbook Name:: cpe_chocolatey
# Recipe:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
unless node['platform_family'] == 'windows'
  return "Chocolatey is not supported on #{node['platform_family']}."
end

# Install chocolatey if not
powershell_script 'Install Chocolatey' do
    action :run
    code "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"
    not_if { ENV.has_key?('ChocolateyInstall') == true }
end

# Configure chocolately to the default repo, configs, etc.
include_recipe 'cpe_chocolatey::configure'

# Install required packages
include_recipe 'cpe_chocolatey::required_apps'
