#
# Cookbook Name:: cpe_user_customizations
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

begin
  user = node.console_user
  include_recipe "cpe_user_customizations::#{user.downcase}"
rescue Chef::Exceptions::RecipeNotFound
  return
rescue Exception => e
  Chef::Log.warn(
    "Error in cpe_user_customizations::#{user.downcase} \n"+
    "#{e.message} \n" +
    "#{e.backtrace.inspect} \n"
  )
end
