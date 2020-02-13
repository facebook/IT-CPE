#
# Cookbook Name:: cpe_nomad
# Resources:: darwin
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

resource_name :cpe_nomad_darwin
provides :cpe_nomad_darwin, :os => 'darwin'
default_action :manage

action :manage do
  configure_install if node['cpe_nomad']['install']
  configure_profile if node['cpe_nomad']['configure']
  configure_launchd if node['cpe_nomad']['enable']
  configure_login if node['cpe_nomad']['login']['install']
end

action_class do
  def configure_install
    pkg = node['cpe_nomad']['pkg']
    cpe_remote_pkg pkg['name'] do
      version pkg['version']
      receipt pkg['receipt']
      checksum pkg['checksum']
      pkg_url pkg['pkg_url'] if pkg['pkg_url']
      pkg_name pkg['pkg_name'] if pkg['pkg_name']
      notifies :restart, "launchd[#{lddomain}]" if node['cpe_nomad']['enable']
      notifies :run, 'ruby_block[log_install]', :immediately
    end

    ruby_block 'log_install' do
      block do
        log_vars('install', 'success')
        msg = (node['cpe_nomad']['pkg']['version']).to_s
        log_if(msg) { node['cpe_nomad']['install'] }
      end
      action :nothing
    end
  end

  def configure_login
    pkg = node['cpe_nomad']['login']['pkg']
    cpe_remote_pkg pkg['name'] do
      version pkg['version']
      receipt pkg['receipt']
      checksum pkg['checksum']
      pkg_url pkg['pkg_url'] if pkg['pkg_url']
      pkg_name pkg['pkg_name'] if pkg['pkg_name']
      notifies :run, 'ruby_block[log_login_install]', :immediately
    end

    ruby_block 'log_login_install' do
      block do
        log_vars('install_login', 'success')
        msg = (node['cpe_nomad']['login']['pkg']['version']).to_s
        log_if(msg) { node['cpe_nomad']['login']['install'] }
      end
      action :nothing
    end
  end

  def configure_profile
    nomad_prefs =
      node['cpe_nomad']['prefs'].reject { |_k, v| v.nil? }
    login_prefs =
      node['cpe_nomad']['login']['prefs'].reject { |_k, v| v.nil? }
    actions_prefs =
      node['cpe_nomad']['actions']['prefs'].reject { |_k, v| v.nil? }
    if [
      nomad_prefs,
      login_prefs,
      actions_prefs,
    ].all?(&:empty?)
      Chef::Log.info("#{cookbook_name}: prefs not found.")
      return
    end

    unless nomad_prefs.empty?
      {
        'PayloadEnabled' => true,
        'PayloadIdentifier' => '7D5A6BCB-1CFD-44BC-ADCF-B511A63F69E3',
        'PayloadDescription' => 'NoMAD Settings',
        'PayloadVersion' => 1,
        'PayloadType' => 'com.trusourcelabs.NoMAD',
        'PayloadUUID' => '7D5A6BCB-1CFD-44BC-ADCF-B511A63F69E3',
      }.each { |k, v| nomad_prefs[k] = v }
    end

    unless login_prefs.empty?
      {
        'PayloadEnabled' => true,
        'PayloadIdentifier' => '94f48d1b-8fbf-4c40-9325-9c3775450250',
        'PayloadDescription' => 'NoMADLoginAD Settings',
        'PayloadVersion' => 1,
        'PayloadType' => 'menu.nomad.login.ad',
        'PayloadUUID' => '94f48d1b-8fbf-4c40-9325-9c3775450250',
      }.each { |k, v| login_prefs[k] = v }
    end

    unless actions_prefs.empty?
      {
        'PayloadEnabled' => true,
        'PayloadIdentifier' => '8c8b263a-2fa1-4471-baf2-9bafdd90e74b',
        'PayloadDescription' => 'NoMAD Actions Settings',
        'PayloadVersion' => 1,
        'PayloadType' => 'menu.nomad.actions',
        'PayloadUUID' => '8c8b263a-2fa1-4471-baf2-9bafdd90e74b',
      }.each { |k, v| actions_prefs[k] = v }
    end

    prefix = node['cpe_profiles']['prefix']
    organization = node['organization'] ? node['organization'] : 'Facebook'

    profile = {
      'PayloadEnabled' => true,
      'PayloadDisplayName' => 'NoMAD',
      'PayloadScope' => 'System',
      'PayloadType' => 'Configuration',
      'PayloadRemovalDisallowed' => true,
      'PayloadDescription' => '',
      'PayloadVersion' => 1,
      'PayloadOrganization' => organization,
      'PayloadIdentifier' => "#{prefix}.nomad",
      'PayloadUUID' => '5312D107-393D-493C-A8D2-14D6E02A0967',
      'PayloadContent' => [],
    }

    [
      nomad_prefs,
      login_prefs,
      actions_prefs,
    ].each do |prefs|
      profile['PayloadContent'] << prefs unless prefs.empty?
    end

    node.default['cpe_profiles'][profile_domain] = profile
  end

  def configure_launchd
    launchd lddomain do
      only_if do
        ::File.exist?("/Library/LaunchAgents/#{lddomain}.plist")
      end
      type 'agent'
      action :nothing
    end
    node.default['fb_launchd']['jobs'][lddomain.split('.')[-1]] =
      node.default['cpe_nomad']['launchagent']
  end

  def profile_domain
    "#{node['cpe_profiles']['prefix']}.nomad"
  end

  def lddomain
    "#{node['fb_launchd']['prefix']}.nomad"
  end

  def log_vars(action, status)
    @type = 'cpe_nomad'
    @action = action
    @status = status
  end

  def log_if(msg)
    CPE::Log.if(
      msg, :type => @type, :action => @action, :status => @status
    ) { yield }
  end
end
