#
# Cookbook Name:: osx_server
# Recipe:: osx_server
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

# OS X SERVER SETUP
directory '/usr/local/libexec' do
  owner 'root'
  group 'wheel'
  mode '0755'
  action :create
end

# Configure OS X Server
server_contents = '/Applications/Server.app/Contents'
server_admin = "#{server_contents}/ServerRoot/usr/sbin/serveradmin"
servercmd = "#{server_contents}/ServerRoot/usr/sbin/server"
server_done = '/var/db/.ServerSetupDone'

unless File.exist?(server_done)
  # Create a temp admin user account
  username = 'serversetup'
  user_pw = username
  user username do
    comment 'serversetup'
    gid 'admin'
    home '/Users/serversetup'
    shell '/bin/bash'
    password user_pw
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
    only_if { File.exist?(serverd) }
    owner 'root'
    group 'wheel'
    mode '0755'
    content lazy { ::File.open(serverd).read }
    action :create
  end

  python 'Server.app' do
    only_if { File.exist?(servercmd) }
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
  user username do
    action :remove
  end
end

# bail if Server.app is not installed
return unless File.exist?(server_admin)

# Set all the NetBoot/NetInstall settings
node['cpe']['imaging_servers']['netboot'].each do |setting, value|
  current_setting = Mixlib::ShellOut.new(
    "#{server_admin} settings #{setting}",
  ).run_command.stdout
  result = "#{setting} = #{value}"
  execute 'Apply NetBoot settings' do
    only_if { File.exist?(server_done) }
    not_if { current_setting.include?(result) }
    command "#{server_admin} settings #{setting}=#{value}"
    notifies :restart, 'service[osx_server_netboot]'
  end
end

# Set all the Caching Server settings
node['cpe']['imaging_servers']['caching'].each do |setting, value|
  current = Mixlib::ShellOut.new(
    "#{server_admin} settings #{setting}",
  ).run_command.stdout
  execute 'Apply Caching settings' do # ~FC022
    only_if { File.exist?(server_done) }
    not_if { current.include?(value) }
    command "#{server_admin} settings #{setting}=#{value}"
    notifies :restart, 'service[osx_server_caching]'
  end
end

# Energy settings
plist_name = 'com.apple.PowerManagement.plist'
plist_location = "/Library/Preferences/SystemConfiguration/#{plist_name}"
cookbook_file plist_location do
  source plist_name
  mode '0644'
  owner 'root'
  group 'wheel'
end

# Set all the Sharing settings
# Compile list of existing shares
sharing = '/usr/sbin/sharing'
share_list = Mixlib::ShellOut.new(
  "#{sharing} -l | grep name:",
).run_command.stdout
sharenames = []
share_list.split("\t\t").each do |share|
  sharenames << share.strip if !share.include?("\t") && !share.include?(':')
end
correct_name = 'DeployStudio'
# Removing existing shares that aren't the one we care about
unless sharenames.sort == [correct_name, 'NetBootSP0'].sort
  sharenames.each do |share|
    execute 'Remove share' do # ~FC022
      only_if { File.exist?(server_done) }
      not_if { share == 'NetBootSP0' || share == correct_name }
      command "#{sharing} -r \"#{share}\""
    end
  end
end

# Create the DeployStudio share for AFP and SMB
correct = node['cpe']['imaging_servers']['sharing_correct']
share_list_full = Mixlib::ShellOut.new(
  "#{sharing} -l",
).run_command.stdout
settings_correct =
  share_list_full.gsub(/\s*/, '').include?(correct.gsub(/\s*/, ''))
if sharenames.include?(correct_name)
  add_or_edit = "-e #{correct_name} "
else
  add_or_edit = "-a #{node['cpe']['imaging_servers']['sharing']['path']} "
end

share_cmd =
  "#{sharing} " +
  add_or_edit +
  "-A #{correct_name} " +
  "-S #{correct_name} " +
  '-s 101 ' +
  '-g 101 ' +
  '-i 00'
execute 'Apply Sharing settings' do
  only_if { File.exist?(server_done) }
  not_if { settings_correct }
  command share_cmd
  notifies :restart, 'service[osx_server_sharing]'
end

# Caching Server as a service
service 'osx_server_caching' do
  # Only do this if the server is fully set up
  only_if { File.exist?(server_done) }
  supports :status => true
  status_command "#{server_admin} status caching | grep -q RUNNING"
  provider Chef::Provider::Service::Simple
  start_command "#{server_admin} start caching"
  stop_command "#{server_admin} stop caching"
  action :start
end

# Netboot/Netinstall as a service
# We must use a .done file because the .nbi can exist before it's ready for use
service 'osx_server_netboot' do
  only_if { File.exist?(server_done) }
  supports :status => true
  status_command "#{server_admin} status netboot | grep -q RUNNING"
  provider Chef::Provider::Service::Simple
  start_command "#{server_admin} start netboot"
  stop_command "#{server_admin} stop netboot"
  action :start
end

# Sharing as a service
service 'osx_server_sharing' do
  only_if { File.exist?(server_done) }
  supports :status => true
  status_command "#{server_admin} status sharing | grep -q RUNNING"
  provider Chef::Provider::Service::Simple
  start_command "#{server_admin} start sharing"
  stop_command "#{server_admin} stop sharing"
  action :start
end
