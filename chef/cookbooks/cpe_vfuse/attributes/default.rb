#
# Cookbook Name:: cpe_vfuse
# Attributes:: default
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2018-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the Apache 2.0 license found in the
# LICENSE file in the root directory of this source tree.
#

default['cpe_vfuse'] = {
  'install' => false,
  'uninstall' => false,
  'template_dir' => nil,
  'templates' => [],
  'pkg' => {
    'name' => 'vfuse',
    'checksum' => nil,
    'receipt' => 'com.github.vfuse',
    'version' => nil,
    'pkg_name' => nil,
    'pkg_url' => nil,
  },
}
