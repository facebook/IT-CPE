# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_autopkg
# Recipe:: default
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

# Will open source soon. You'll need to install AutoPkg with something else,
# like Munki.

# Install Autopkg
# cpe_remote_pkg 'autopkg' do
#   only_if { node['cpe_autopkg']['install'] }
#   version '0.6.1'
#   checksum 'c0c64a8c97c67f8a73a3450ebb19a2747c5800cf474b2fb6c12e4f6cb41316c0'
#   receipt 'com.github.autopkg.autopkg'
# end

return unless node.macos?

cpe_autopkg_setup 'Set up AutoPkg'
cpe_autopkg_update 'Add/Update AutoPkg repos'
