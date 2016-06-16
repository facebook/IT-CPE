#
# Cookbook Name:: cpe_init
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

# To be open sourced soon
# include_recipe 'cpe_chef_client'
include_recipe "cpe_init::#{node['platform_family']}_init"

include_recipe 'cpe_user_customizations'
include_recipe 'cpe_node_customizations'
