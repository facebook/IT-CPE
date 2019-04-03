# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_macos_server
# Resource:: cpe_macos_server
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_macos_server
default_action :setup

server_done = '/var/db/.ServerSetupDone'
server_contents = '/Applications/Server.app/Contents'

action :setup do
  return unless node['cpe_macos_server']['setup']
  if ::File.exist?(server_done)
    Chef::Log.info("#{cookbook_name}: Server.app already set up.")
    return
  end

  # Configure OS X Server for the first time
  servercmd = "#{server_contents}/ServerRoot/usr/sbin/server"

  # Create a temp admin user account
  username = 'serversetup'
  user_pw = username
  user 'serversetup_create' do
    comment 'serversetup'
    gid 'admin'
    home '/Users/serversetup'
    shell '/bin/bash'
    password user_pw
    username username
    action :create
  end

  priv_helper_dir = '/Library/PrivilegedHelperTools'
  directory priv_helper_dir do
    owner 'root'
    group 'wheel'
    action :create
  end

  serverd = "#{server_contents}/Library/LaunchServices/com.apple.serverd"
  file "#{priv_helper_dir}/com.apple.serverd" do
    only_if { ::File.exist?(serverd) }
    owner 'root'
    group 'wheel'
    mode '0755'
    content lazy { ::File.open(serverd).read }
    action :create
  end

  python 'Server.app' do
    only_if { ::File.exist?(servercmd) }
    creates '/var/db/.ServerSetupDone'
    cwd '/Library/CPE/lib/flib/modules/'
    code <<-EOH
import sys
sys.path.append('/Library/CPE/lib/flib/modules')
import pexpect
server_eula = pexpect.spawn('#{servercmd} setup', timeout=300)
server_eula.logfile = sys.stdout
# server_eula.expect("Press Return to view the software license agreement.")
server_eula.sendline(' ')
server_eula.expect("(y/N)")
server_eula.sendline('y')
server_eula.expect("User name:")
server_eula.sendline('#{username}')
server_eula.expect("Password:")
server_eula.sendline('#{user_pw}')
try:
  server_eula.expect(pexpect.TIMEOUT, timeout=None)
except:
  pass
sys.exit(0)
    EOH
    action :run
  end

  # Remove the temp admin account
  user 'serversetup_delete' do
    username username
    action :remove
  end
end

action :apply do
  return unless node['cpe_macos_server']['manage']
  # Bail if Server.app is not installed, or not configured
  unless ::File.exist?(server_done)
    Chef::Log.info("#{cookbook_name}: Server.app not set up.")
    return
  end

  server_admin = "#{server_contents}/ServerRoot/usr/sbin/serveradmin"
  # Get all the keys that are services
  servicelist = node['cpe_macos_server']['services'].keys

  servicelist.each do |service|
    # Get list of settings to apply
    settinglist = node['cpe_macos_server']['services'][service]
    # Apply each setting key/value pair
    settinglist.each do |setting, value|
      cpe_macos_server_setting setting do
        value value
      end
    end
    # Start the service
    service "server_#{service}" do
      # Only do this if the server is fully set up
      only_if { ::File.exist?(server_done) }
      supports :status => true
      status_command "#{server_admin} status #{service} | grep -q RUNNING"
      provider Chef::Provider::Service::Simple
      start_command "#{server_admin} start #{service}"
      stop_command "#{server_admin} stop #{service}"
      action :start
    end
  end
end
