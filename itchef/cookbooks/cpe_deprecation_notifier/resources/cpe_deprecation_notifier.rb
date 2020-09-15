# ~FC074
# Cookbook Name:: cpe_deprecation_notifier
# Resource:: cpe_deprecation_notifier
#
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
#

resource_name :cpe_deprecation_notifier
provides :cpe_deprecation_notifier, :os => 'darwin'
default_action :prompt

action :prompt do
  dpn = node['cpe_deprecation_notifier'].to_h
  la_path = '/Library/LaunchAgents'
  launchd_prefix = node['fb_launchd']['prefix']
  domain = "#{launchd_prefix}.deprecationnotifier"
  launchagent_path = "#{la_path}/#{domain}.plist"

  if dpn['install']
    # Force a re-install if someone has removed the binary
    unless ::File.exist?("#{dpn['path']}/Contents/MacOS/DeprecationNotifier")
      Chef::Log.info('DeprecationNotifier not present, reinstalling')
      shell_out("/usr/sbin/pkgutil --forget #{dpn['pkg_reciept']}")
    end

    # Upgrade Version
    cpe_remote_pkg 'DeprecationNotifier' do
      version dpn['version']
      checksum dpn['checksum']
      receipt dpn['pkg_reciept']
      notifies :restart, "launchd[#{domain}]" if dpn['enable']
    end
  end

  if dpn['enable']
    # Write our strings file, this manages the text in the popup
    template 'localizable_strings' do # ~FB031
      only_if { dpn['path'] && ::Dir.exist?(dpn['path']) }
      path "#{dpn['path']}/Contents/Resources/en.lproj/Localizable.strings"
      source 'Localizable.strings.erb'
      owner 'root'
      group 'wheel'
      mode '0755'
      notifies :restart, "launchd[#{domain}]"
      notifies :write, 'macos_userdefaults[Reset Timeout]'
    end

    macos_userdefaults 'Reset Timeout' do
      action :nothing
      domain 'com.megacorp.DeprecationNotifier'
      user node.person['username'] # ~FB039
      key 'WindowTimeOut'
      value dpn['conf']['initialTimeout']
      type 'int'
    end

    # We're gonna try to do some logic here so that we don't
    # unnecessarily load the LaunchDaemon when we don't need to
    os_build = node.attr_lookup('platform_build', :default => nil) # ~FB039
    ev = dpn['conf']['expectedVersion']
    eb = dpn['conf']['expectedBuilds']
    should_launch = false
    if ev.nil?
      # We didn't specify a version, so let's not config
      should_launch = false
    elsif node.os_less_than?(ev)
      # OS is less than expectedVersion, definitely config
      should_launch = true
    elsif node.os_at_most?(ev)
      # It's not less, and it's not greater, so it's equal
      if eb.nil?
        # We didn't specify a build, so we're in compliance
        should_launch = false
      else
        # We did specify allowlisted builds and we're on
        # an equal OS version, so let's check them
        if eb.include?(os_build)
          # Our build is in the allowlist, nothing to do
          should_launch = false
        else
          # Builds are specified and we're not in them
          should_launch = true
        end
      end
    end

    log_vars('expected_version', 'fail')
    if log_if(dpn['conf']['expectedVersion'].to_s) { should_launch }
      dp_bin = "#{dpn['path']}/Contents/MacOS/DeprecationNotifier"
      node.default['fb_launchd']['jobs']['deprecationnotifier'] = {
        'program_arguments' => [dp_bin],
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

action_class do
  def log_vars(action, status)
    @type = 'cpe_deprecation_notifier'
    @action = action
    @status = status
  end

  def log_if(msg)
    CPE::Log.if(
      msg, :type => @type, :action => @action, :status => @status
    ) { yield }
  end
end
