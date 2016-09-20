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

default['cpe_macos_server'] = {
  # These attributes determine API behavior
  'setup' => false,
  'manage' => false,
  'services' => {
    # These attributes are for configuring Server.app
    # Each key should be the name of a service from:
    # `sudo serveradmin list`
    # Each key within should be the name of a setting from:
    # `sudo serveradmin settings <service>`
    # 'caching' => {
    #   # Keep at least 25 GB of the disk free
    #   'caching:ReservedVolumeSpace' => '25000000000',
    #   # cache limit: 80 GB
    #   'caching:CacheLimit' => '80000000000',
    #   # local subnets only
    #   'caching:LocalSubnetsOnly' => 'yes',
    # },
    # 'afp' => {
    #   # Disable guest access
    #   'afp:guestAccess' => 'no',
    # },
  },
}
