#
# Cookbook Name:: cpe_init
# Recipe:: mac_os_x_init
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

run_list = []

# HERE: This is your recipe to place settings and additional cookbooks you
# would like to include
run_list += [
  'cpe_init::company_init',
]

# API Cookbooks go last
if node.macos?
  run_list += [
    'cpe_desktop',
    'cpe_bluetooth',
    'cpe_hosts',
    'cpe_pathsd',
    'cpe_safari',
    'cpe_screensaver',
    'cpe_powermanagement',
    # HERE: Coming soon! Will be opensourced at a later date
    # 'cpe_chrome',
    # 'cpe_firefox',
    # 'cpe_firewall_config',
    # 'cpe_splunk',
    # Here Be Dragons... Ordering is important.
    # launchd and profiles need to be last, as other apis depend on these
    'cpe_munki',
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
