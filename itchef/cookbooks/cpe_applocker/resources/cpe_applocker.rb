# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: cpe_applocker
# Resource:: applocker
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

resource_name :cpe_applocker
provides :cpe_applocker, :os => 'windows'
default_action :configure
property :applocker_rules, Hash

# Before processing our action, we first derive the current state of Applocker
# on the local system to ensure that we only process if the configuration state
# has changed.
load_current_value do
  extend CPE::Applocker
  begin
    # In order to ensure we can process policies with non-US char sets
    # We firest set the 'code page' of Windows to UTF-8 with chcp. This
    # is only active for the shell out session, and resets after exit.
    current_state = powershell_out(
      'chcp 65001 | Out-Null; Get-ApplockerPolicy -Effective -Xml',
    ).stdout
  rescue
    Chef::Log.warn('Failed to retrieve the effective AppLocker policy')
  end

  xml = Nokogiri::XML(current_state)
  unless xml.errors.empty?
    Chef::Log.error(
      "Failed to parse Applocker policy from system with #{xml.errors}",
    )
    # Return so we don't tank the Chef run
    return
  end
  applocker_rules xml_to_hash(xml)
end

action_class do
  include CPE::Applocker

  def uninstall_applocker
    # Disable autostart of the service. A common theme I've seen is that one
    # cannot disable the AppIDSvc service, even as SYSTEM, via CLI utils. A
    # "hack" I found online was to modify the services registry configuration
    # for startup, which is sufficient for our needs.
    appidsvc = 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet' +
               '\\Services\\AppIDSvc'
    registry_key appidsvc do
      values [{
        :name => 'Start',
        :type => :dword,
        :data => 3,
      }]
      action :create
    end

    # Lastly stop the service
    service 'AppIDSvc' do
      supports :restart => true, :stop => true
      action [:stop]
    end
  end

  def configure_applocker
    return unless node['cpe_applocker']['enabled']
    # Applocker is installed by turning on the Application ID Service, we
    # handle the configuration of the 4 rules in the `configure` step
    service 'AppIDSvc' do
      supports :restart => true, :stop => true
      action [:enable, :start]
    end
  end
end

action :uninstall do
  converge_if_changed :applocker_rules do
    set_applocker_policy
  end
  # Lastly disable the service and set the startup type to manual
  uninstall_applocker
end

action :configure do
  converge_if_changed :applocker_rules do
    set_applocker_policy
  end
  # We always want to ensure the service is online
  configure_applocker
end
