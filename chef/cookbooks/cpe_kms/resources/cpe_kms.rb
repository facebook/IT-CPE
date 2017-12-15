#
# Cookbook Name:: cpe_kms
# Resource:: cpe_kms
#
# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Copyright (c) 2017-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_kms
default_action :config
provides :cpe_kms, :os => 'windows'

action :config do
  return unless node.windows?
  kms_path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion' +
    '\SoftwareProtectionPlatform'
  registry_key kms_path do
    only_if { node['cpe_kms'].values.any? }
    values create_registry_hash(node['cpe_kms'])
    recursive true
  end
end
