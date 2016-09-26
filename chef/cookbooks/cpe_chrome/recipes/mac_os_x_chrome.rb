#
# Cookbook Name:: cpe_chrome
# Recipe:: mac_os_x_chrome
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

node.default['cpe_munki']['local']['managed_installs'] << 'GoogleChrome'

return unless node.installed?('com.google.Chrome')

cpe_chrome 'Configure Google Chrome'
