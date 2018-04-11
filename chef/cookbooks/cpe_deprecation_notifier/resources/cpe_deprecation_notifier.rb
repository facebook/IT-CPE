#
# Cookbook Name:: cpe_deprecation_notifier
# Resource:: cpe_deprecation_notifier
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

resource_name :cpe_deprecation_notifier
default_action :prompt

action :prompt do
  dpn = node['cpe_deprecation_notifier'].to_h
  la_path = '/Library/LaunchAgents'
  domain = "#{node['cpe_launchd']['prefix']}.deprecationnotifier"
  launchagent_path = "#{la_path}/#{domain}.plist"

  if dpn['install']
    # Force a re-install if someone has removed the binary
    unless ::File.exist?("#{dpn['path']}/Contents/MacOS/DeprecationNotifier")
      Chef::Log.info('DeprecationNotifier not present, reinstalling')
      Mixlib::ShellOut.new("pkgutil --forget #{dpn['pkg_reciept']}").run_command
    end

    # Upgrade Version
    cpe_remote_pkg 'DeprecationNotifier' do # ~FC037
      version dpn['version']
      checksum dpn['checksum']
      receipt dpn['pkg_reciept']
      notifies :restart, "launchd[#{domain}]" if dpn['enable']
    end
  end

  if dpn['enable']
    # Write our strings file, this manages the text in the popup
    template 'localizable_strings' do # ~FC037
      only_if { dpn['path'] && ::Dir.exist?(dpn['path']) }
      path "#{dpn['path']}/Contents/Resources/en.lproj/Localizable.strings"
      source 'Localizable.strings.erb'
      owner 'root'
      group 'wheel'
      mode '0755'
      notifies :restart, "launchd[#{domain}]"
    end

    if node.os_less_than?(dpn['conf']['expectedVersion'])
      dp_bin = "#{dpn['path']}/Contents/MacOS/DeprecationNotifier"
      p_arg = [dp_bin]
      if dpn['log_path']
        log = dpn['log_path']
        p_arg = [
          'bash',
          '-c',
          'echo "{\"last_prompt\": \"`date +%s`\"}" > ' + "#{log}; #{dp_bin}",
        ]
      end
      node.default['cpe_launchd'][domain] = {
        'program_arguments' => p_arg,
        'run_at_load' => true,
        'type' => 'agent',
      }
    end

    # To be used only for restarting
    launchd domain do # ~FC009
      only_if { ::File.exist?(launchagent_path) }
      type 'agent'
      action :nothing
    end
  end
end
