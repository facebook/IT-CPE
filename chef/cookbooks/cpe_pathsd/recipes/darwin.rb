#
# Cookbook Name:: cpe_pathsd
# Recipe:: darwin
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

directory '/etc/paths.d/' do
  owner 'root'
  group 'wheel'
  mode 0755
end

template '/etc/paths.d/cpe_pathsd' do
  source 'cpe_pathsd'
  owner 'root'
  group 'wheel'
  mode 0644
end
