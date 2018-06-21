# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
# Encoding: utf-8

# Cookbook Name:: cpe_munki
# Resource:: cpe_munki_install
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#

resource_name :cpe_munki_install
default_action :install

action_class do
  def managed_installs
    '/Library/Preferences/ManagedInstalls'
  end

  def read_munki_lastcheckdate
    begin
      defaults_cmd = Mixlib::ShellOut.new(
        "/usr/bin/defaults read #{managed_installs} LastCheckDate",
      ).run_command.stdout
      last_check_date = Date.parse(defaults_cmd)
    rescue ArgumentError
      log("Unable to parse LastCheckDate: #{defaults_cmd}")
      last_check_date = Date.today
    end
    last_check_date
  end

  def write_munki_lastcheckdate(time)
    execute "defaults write #{managed_installs} LastCheckDate '#{time}'"
  end

  def remediate?
    return unless node['cpe_munki']['auto_remediate']
    # There is a chance that this is prior to the first run,
    # file might not be present.
    return unless ::File.exist?("#{managed_installs}.plist")
    # getting value for the last munki check-in
    last_check_date = read_munki_lastcheckdate
    # if it's greater than the remediate_window since munki last ran.
    today = Date.today
    remediate_window = node['cpe_munki']['auto_remediate'].to_i
    return unless (today - last_check_date).to_i > remediate_window

    # and the pkg is installed
    node['cpe_munki']['munki_version_to_install'].to_h.each do |pkg, _opts|
      receipt = "com.googlecode.munki.#{pkg}"
      next if Mixlib::ShellOut.new(
        "/usr/sbin/pkgutil --pkg-info='#{receipt}'",
      ).run_command.error?
      # forget the pkg
      execute "/usr/sbin/pkgutil --forget #{receipt}"
    end
    write_munki_lastcheckdate(Time.now)
  end
end

action :install do
  return unless node['cpe_munki']['install']
  m = 'com.googlecode.munki'
  remediate?
  node['cpe_munki']['munki_version_to_install'].to_h.each do |pkg, opts|
    package_version = opts['version']
    app_name = opts['app_name'] ? opts['app_name'] : 'munkitools'
    package_name = "munkitools_#{pkg}-#{package_version}"
    cpe_remote_pkg "munkitools_#{pkg}" do # ~FC037
      app app_name
      pkg_name package_name
      pkg_url opts['url'] if opts['url']
      checksum opts['checksum']
      receipt "com.googlecode.munki.#{pkg}"
      version package_version
      if pkg.include?('launchd')
        notifies :restart, "launchd[#{m}.logouthelper]"
        notifies :restart, "launchd[#{m}.managedsoftwareupdate-check]"
        notifies :restart, "launchd[#{m}.managedsoftwareupdate-manualcheck]"
        notifies :restart, "launchd[#{m}.authrestartd]"
        notifies :restart, "launchd[#{m}.managedsoftwareupdate-install]"
        notifies :restart, "launchd[#{m}.app_usage_monitor]"
        notifies :restart, "launchd[#{m}.munki-notifier]"
        notifies :restart, "launchd[#{m}.ManagedSoftwareCenter]"
      end
    end
  end

  [
    'logouthelper',
    'managedsoftwareupdate-check',
    'managedsoftwareupdate-manualcheck',
    'authrestartd',
    'managedsoftwareupdate-install',
    'app_usage_monitor',
  ].each do |d|
    launchd "#{m}.#{d}" do
      only_if { ::File.exist?("/Library/LaunchDaemons/#{m}.#{d}.plist") }
      action :enable
    end
  end

  [
    'munki-notifier',
    'ManagedSoftwareCenter',
  ].each do |a|
    launchd "#{m}.#{a}" do
      only_if { ::File.exist?("/Library/LaunchAgents/#{m}.#{a}.plist") }
      type 'agent'
      action :enable
    end
  end
end
