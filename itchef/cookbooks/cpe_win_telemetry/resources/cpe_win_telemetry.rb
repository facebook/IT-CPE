# Copyright (c) Facebook, Inc. and its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Cookbook Name:: cpe_win_telemetry
# Resource:: cpe_win_telemetry

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
        action %i{disable stop}
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
