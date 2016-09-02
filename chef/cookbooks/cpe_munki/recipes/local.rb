# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_munki
# Recipe:: local
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

return unless node.macosx?

locals_exist = node['cpe_munki']['local']['managed_installs'].any? ||
               node['cpe_munki']['local']['managed_uninstalls'].any?
# If any local installs are specified but the local only manifest preference
# is not set, set it to the default 'extra_packages'

if locals_exist && !node['cpe_munki']['preferences'].key?('LocalOnlyManifest')
  node.default['cpe_munki']['preferences']['LocalOnlyManifest'] =
    'extra_packages'
end

cpe_munki 'Manage Local Munki Manifest'
