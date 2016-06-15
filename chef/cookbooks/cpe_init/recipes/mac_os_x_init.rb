# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8
# Cookbook Name:: cpe_init
# Recipe:: mac_os_x_init
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
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

# This is your recipe to place settings
run_list += [
  'cpe_init::company_init'
]

# API Cookbooks go last
if node.macos?
  run_list += [
    'cpe_pathsd',
    'cpe_bluetooth',
    'cpe_chrome',
    'cpe_firefox',
    'cpe_hosts',
    'cpe_powermanagement',
    'cpe_safari',
    'cpe_screensaver',
    # Here Be Dragons... Ordering is important.
    # launchd and profiles need to be last, as other apis depend on these
    'cpe_launchd',
    'cpe_profiles',
  ]
end


# Log run_list
runlist_log_cmd = "logger -t CPE-init 'Run_list: #{run_list.uniq}'"
Mixlib::ShellOut.new(runlist_log_cmd).run_command
Chef::Log.info("Run_list: #{run_list.uniq}")

# Include all cookbooks from the run_list
run_list.uniq.each do |recipe|
  include_recipe recipe
end
