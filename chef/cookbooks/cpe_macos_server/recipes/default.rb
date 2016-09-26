# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_macos_server
# Recipe:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

# You must install Server.app first
unless File.exist?('/Applications/Server.app')
  Chef::Log.info("#{cookbook_name}: Server.app is not installed.")
  return
end

cpe_macos_server 'Set up Server.app'

cpe_macos_server 'Apply Server.app settings' do
  action :apply
end
