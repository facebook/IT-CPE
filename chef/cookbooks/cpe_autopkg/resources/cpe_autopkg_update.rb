# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8
# Cookbook Name:: cpe_autopkg
# Resource:: cpe_autopkg_update
#
# Copyright 2016, Nick McSpadden
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :cpe_autopkg_update
default_action :update

AUTOPKG_BIN = '/usr/local/bin/autopkg'.freeze

action :update do
  return unless node['cpe_autopkg']['update']
  # Get list of existing repos first
  repo_list = Mixlib::ShellOut.new(
    'autopkg repo-list',
    :user => node['cpe_autopkg']['user'],
  ).run_command.stdout.split("\n")
  # Add or update all the existing repos
  node['cpe_autopkg']['repos'].each do |repo|
    execute "add_#{repo}" do
      only_if { ::File.exist?(AUTOPKG_BIN) }
      not_if { repo_list.any? { |s| s.include?(repo) } }
      user node['cpe_autopkg']['user']
      command "#{AUTOPKG_BIN} repo-add #{repo}"
    end
  end
end
