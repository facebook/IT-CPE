# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_remove_teamviewer
# Recipe:: default
#
# Copyright 2016-Present, Facebook
#
# All rights reserved - Do Not Redistibute
#

tv_paths = CPE.app_paths('com.teamviewer.TeamViewer')
Chef::Log.info(
  "#{cookbook_name}/#{recipe_name}: Found Teamviewer at #{tv_paths}"
) if tv_paths

tv_launchds = [
  'com.teamviewer.Helper',
  'com.teamviewer.teamviewer_service'
]

tv_launchas = [
  'com.teamviewer.teamviewer',
  'com.teamviewer.teamviewer_desktop'
]

tv_launchds.each do |tv_launchd|
  launchd tv_launchd do
    action :delete
  end
end

tv_launchas.each do |tv_launcha|
  launchd tv_launcha do
    type 'agent'
    action :delete
  end
end

security_agent =
  '/Library/Security/SecurityAgentPlugins/TeamViewerAuthPlugin.bundle'
directory security_agent do
  recursive true
  action :delete
end

helper =
  '/Library/PrivilegedHelperTools/com.teamviewer.Helper'
file helper do
  action :delete
end

font =
  '/Library/Fonts/TeamViewer11.otf'
file font do
  action :delete
end

%w(
  com.teamviewer.teamviewer11
  com.teamviewer.teamviewer11Agent
  com.teamviewer.teamviewer11AuthPlugin
  com.teamviewer.teamviewer11Font
  com.teamviewer.teamviewer11PriviledgedHelper
  com.teamviewer.teamviewer11Restarter
).each do |pkg_receipt|
  execute pkg_receipt do
    only_if { CPE.installed?('com.teamviewer.TeamViewer') }
    command "/usr/sbin/pkgutil --forget #{pkg_receipt}"
    ignore_failure true
  end
end

# Finally, delete the app itself
tv_paths.each do |app_path|
  Chef::Log.info("#{cookbook_name}/#{recipe_name}: Removing app at #{app_path}")
  directory app_path do
    recursive true
    action :delete
  end
end
