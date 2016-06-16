#
# Cookbook Name:: cpe_init
# Recipe:: company_init
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

# HERE: This is where you would set attributes that are consumed by the API
# cookbooks.
# Be sure to replace all instances of MYCOMPANY with your actual company name
node.default['organization'] = 'MYCOMPANY'
node.default['cpe_launchd']['prefix'] = 'com.MYCOMPANY.chef'
node.default['cpe_profiles']['prefix'] = 'com.MYCOMPANY.chef'


# Install munki
node.default['cpe_munki']['install'] = true
# Configure muni
node.default['cpe_munki']['configure'] = true
# Override default munki settings
node.default['cpe_munki']['preferences']['SoftwareRepoURL'] =
  'https://munki.MYCOMPANY.com/repo'
node.default['cpe_munki']['preferences']['InstallAppleSoftwareUpdates'] = true
# Manage Local Munki Manifest
managed_installs = [
  # Put managed install items here
]
managed_installs.each do |item|
  node.default['cpe_munki']['local']['managed_installs'] << item
end
