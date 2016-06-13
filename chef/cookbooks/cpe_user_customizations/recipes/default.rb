# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_user_customizations
# Recipe:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
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

begin
  user = node.console_user
  include_recipe "cpe_user_customizations::#{user}"
rescue Chef::Exceptions::RecipeNotFound
  return
rescue Exception => e
  Chef::Log.warn(
    "Error in cpe_user_customizations::#{user} \n"+
    "#{e.message} \n" +
    "#{e.backtrace.inspect} \n"
  )
end
