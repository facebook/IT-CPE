# Cookbook Name:: cpe_init
# Recipe:: default
#
# Copyright (c) Facebook, Inc. and its affiliates.
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

run_list = []

# HERE: This is your recipe to place settings and additional cookbooks you
# would like to include
run_list += [
  'cpe_init::company_init',
]

# API Cookbooks
# Cross-platform
run_list += [
  'cpe_chrome',
  # 'cpe_hosts', # requires 'line' community cookbook
  'cpe_remote',
]

# Unix-like platforms only
unless node.windows?
  run_list += [
    'cpe_logger',
    'cpe_pathsd',
    'cpe_symlinks',
  ]
end

if node.macos?
  run_list += [
    'cpe_bluetooth',
    'cpe_deprecation_notifier',
    'cpe_munki',
    'cpe_powermanagement',
    'cpe_preferencepanes',
    'cpe_spotlight',
    'cpe_vfuse',
    # Here Be Dragons... Ordering is important.
    # launchd and profiles need to be last, as other apis depend on these
    'cpe_launchd',
    'cpe_profiles',
  ]
elsif node.windows?
  run_list += [
    'cpe_applocker',
    'cpe_win_telemetry',
  ]
elsif node.linux?
  run_list += [
    'cpe_dconf',
    'cpe_flatpak',
    'cpe_gnome_software',
  ]
end

# these go last so users can override settings
include_recipe 'cpe_user_customizations'
include_recipe 'cpe_node_customizations'

# Log run_list
runlist_log_cmd = "logger -t CPE-init 'Run_list: #{run_list.uniq}'"
Mixlib::ShellOut.new(runlist_log_cmd).run_command
Chef::Log.info("Run_list: #{run_list.uniq}")

# Include all cookbooks from the run_list
run_list.uniq.each do |recipe|
  include_recipe recipe
end
