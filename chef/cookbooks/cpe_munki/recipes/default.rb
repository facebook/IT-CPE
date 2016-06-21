#
# Cookbook Name:: cpe_munki
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

include_recipe 'cpe_munki::install' if node['cpe_munki']['install']
include_recipe 'cpe_munki::local'
include_recipe 'cpe_munki::config' if node['cpe_munki']['configure']

if node['cpe_munki']['munkireports']['install']
  include_recipe 'cpe_munki::munkireports'
end
