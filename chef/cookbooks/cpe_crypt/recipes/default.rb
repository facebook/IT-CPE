# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_crypt
# Recipe:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

return unless node.macos?

# Manage Crypt Install
cpe_crypt_install 'Install Crypt'

# Manage authorizationdb for Crypt Auth plugin
cpe_crypt_configure 'Configure authorizationdb'
