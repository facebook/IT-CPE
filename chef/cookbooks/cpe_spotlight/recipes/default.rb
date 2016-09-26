# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_spotlight
# Recipe:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

return unless node.macosx?
# Abort if Spotlight indexing is disabled
spotlight_data =
  Mixlib::ShellOut.new('/usr/bin/mdutil -s /').run_command.stdout

return if spotlight_data.include?('No index.') ||
          spotlight_data.include?('Spotlight server is disabled.')

directory '/private/var/chef' do
  owner 'root'
  group 'wheel'
  mode '0755'
  action :create
end

cpe_spotlight 'Manage Spotlight exclusions'

cpe_spotlight 'Clean up removed Spotlight exclusions' do
  action :clean_up
end
