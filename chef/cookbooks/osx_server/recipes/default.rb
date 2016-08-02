#
# Cookbook Name:: cpe_imaging_servers
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

return unless node.macosx?

# Configure service directories, account
include_recipe 'cpe_imaging_servers::setup'

# Configure and enable OS X Server.app services
include_recipe 'cpe_imaging_servers::osx_server'