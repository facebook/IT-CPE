# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_choco
# Recipe:: default
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
return unless platform?('windows')

cpe_choco_bootstrap 'bootstrap if needed'
cpe_choco_configure 'configuring chocolatey client'
cpe_choco_apps 'managing system applications'
