# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco
# Recipe:: install
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

unless node['platform_family'] == 'windows'
  Chef::Log.warn("Chocolatey is not supported on #{node['platform_family']}.")
  return
end

powershell_script 'chocolatey_install' do
    not_if { ENV.has_key?('ChocolateyInstall') }
    code <<-EOF
$web_client = New-Object System.Net.WebClient
$installation_script = '#{node['cpe_choco']['installation_uri']}'
Invoke-Expression $web_client.DownloadString($installation_script)
EOF
    action :run
end
