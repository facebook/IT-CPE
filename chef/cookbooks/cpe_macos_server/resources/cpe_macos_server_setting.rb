# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_macos_server
# Resource:: cpe_macos_server_setting
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_macos_server_setting
default_action :apply

# rubocop:disable Style/HashSyntax
property :key, String, name_property: true
property :value, [String, Integer]
# rubocop:enable Style/HashSyntax

action :apply do
  server_done = '/var/db/.ServerSetupDone'
  server_contents = '/Applications/Server.app/Contents'
  server_admin = "#{server_contents}/ServerRoot/usr/sbin/serveradmin"
  current = Mixlib::ShellOut.new(
    "#{server_admin} settings #{key}",
  ).run_command.stdout
  execute "Apply #{key}" do
    only_if { ::File.exist?(server_done) }
    not_if { current.include?(value) }
    command "#{server_admin} settings #{key}=#{value}"
  end
end
