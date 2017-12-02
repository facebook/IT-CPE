#
# Cookbook Name:: cpe_win_telemetry
# Resource:: cpe_win_telemetry
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

resource_name :cpe_win_telemetry
default_action :config
provides :cpe_win_telemetry, :os => 'windows'

action :config do
  return unless node.windows? && node.os_at_least?('10.0.15063')
  if node['cpe_win_telemetry']['AllowTelemetry'] == -1
    ['DiagTrack', 'dmwappushservice'].each do |svc_name|
      # Disable these services to kill telemetry data to Microsoft
      windows_service svc_name do
        startup_type :disabled
        action [:disable, :stop]
      end
    end
    # Reset Telemetry to min allowed value
    node.default['cpe_win_telemetry']['AllowTelemetry'] = 0
  end
  telemetry_path =
    'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection'
  registry_key telemetry_path do
    only_if { node['cpe_win_telemetry'].values.any? }
    values create_registry_hash(node['cpe_win_telemetry'])
    recursive true
  end
end
