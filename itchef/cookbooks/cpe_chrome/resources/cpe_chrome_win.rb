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

# Cookbook Name:: cpe_chrome
# Resources:: cpe_chrome_win

resource_name :cpe_chrome_win
provides :cpe_chrome, :os => 'windows'
default_action :config

action :config do
  # check file path for Chrome since osquery doesn't detect
  # chrome is installed on all machines
  chrome_installed = ::File.file?(
    "#{ENV['ProgramFiles(x86)']}\\Google\\Chrome\\Application\\chrome.exe",
  ) || ::File.file?(
    "#{ENV['ProgramFiles']}\\Google\\Chrome\\Application\\chrome.exe",
  )
  return unless chrome_installed || node.installed?('Google Chrome')
  return unless node['cpe_chrome']['profile'].values.any?

  reg_settings = set_reg_settings(node)
  doomed_policies = policies_to_remove

  reg_file_path = ::File.join(Chef::Config[:file_cache_path], 'chrome.reg')

  policy_settings = gen_reg_file_settings(
    doomed_policies, reg_settings
  )
  template reg_file_path do
    source 'chrome_Settings.reg.erb'
    variables(:policies => policy_settings)
    rights :read, 'Everyone', :applies_to_children => true
    rights :read_execute, 'Users', :applies_to_children => true
    rights :full_control, ['Administrators', 'SYSTEM'],
           :applies_to_children => true
    action :create
    only_if { verify_update_needed(policy_settings) }
  end

  powershell_script 'import reg file' do
    code <<-EOT
     $process = Start-Process reg -NoNewWindow -ArgumentList "import #{reg_file_path}" -PassThru -Wait
     Exit $process.ExitCode
    EOT
    only_if { verify_update_needed(policy_settings) }
  end

  # This cookbook configures extension settings using the value
  # "ExtensionSettings" at the key "HKLM\SOFTWARE\Policies\Google\Chrome".
  # We need to remove the key at "HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionSettings"
  # or else chrome may incorrectly use that to set extension policies instead.
  extension_settings_key =
    'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionSettings'
  registry_key extension_settings_key do
    action :delete_key
    recursive true
  end

  # Manage Extension Settings
  extprefs = node['cpe_chrome']['extension_profile']
  if extprefs.empty? || extprefs.nil?
    registry_key CPE::ChromeManagement.chrome_reg_3rd_party_ext_root do
      recursive true
      action :delete_key
    end
  else
    # Loop through the extensions and create registry entries
    # Key path is HKLM\Software\Policies\Google\Chrome\3rdparty\extensions\EXT_ID\policy
    # https://www.chromium.org/administrators/configuring-policy-for-extensions
    extprefs.each do |k, v|
      ext_values = []
      v['profile'].each do |k_ext, v_ext|
        ext_values << {
          'name' => k_ext,
          'type' => v_ext['windows_value_type'],
          'data' => v_ext['value'],
        }
      end
      reg_key_path =
        "#{CPE::ChromeManagement.chrome_reg_3rd_party_ext_root}\\#{k}\\policy"
      registry_key reg_key_path do
        values ext_values
        recursive true
        action :create
      end
    end
  end

  # There are two migrations going on here.  From the legacy x86
  # program files to the x86_64 one, and from master_preferences to
  # initial_preferences.  At time of writing, we have Chrome instances
  # installed in both locations.  While we probably do not have any
  # chromes old enough to be unaware of the new initial_preferences
  # file name, we might, and the current files use that name.  It's
  # safer to just keep creating it until we're sure everything is on
  # the new name.
  ['initial_preferences', 'master_preferences'].each do |basename|
    [
      'C:\\Program Files (x86)\\',
      'C:\\Program Files\\',
    ].each do |prefix|

      pref_path = "#{prefix}\\Google\\Chrome\\Application\\#{basename}"
      file "delete-#{pref_path}" do
        only_if do
          node['cpe_chrome']['mp']['FileContents'].
            to_hash.
            reject { |_k, v| v.nil? }.
            empty?
        end
        path pref_path
        action :delete
      end

      [
        "#{prefix}\\Google",
        "#{prefix}\\Google\\Chrome",
        "#{prefix}\\Google\\Chrome\\Application",
      ].each do |dir|
        directory dir do # rubocop:disable Chef/Meta/RequireOwnerGroupMode # ~FB024
          rights :read, 'Everyone', :applies_to_children => true
          rights :read_execute, 'Users', :applies_to_children => true
          rights :full_control, ['Administrators', 'SYSTEM'],
                 :applies_to_children => true
          action :create
        end
      end

      file "create-#{pref_path}" do # rubocop:disable Chef/Meta/RequireOwnerGroupMode # ~FB023
        not_if do
          node['cpe_chrome']['mp']['FileContents'].
            to_hash.
            reject { |_k, v| v.nil? }.
            empty?
        end
        content lazy {
          Chef::JSONCompat.to_json_pretty(
            node['cpe_chrome']['mp']['FileContents'].
              to_hash.
              reject { |_k, v| v.nil? },
          )
        }
        path pref_path
        rights :read, 'Everyone', :applies_to_children => true
        rights :read_execute, 'Users', :applies_to_children => true
        rights :full_control, ['Administrators', 'SYSTEM'],
               :applies_to_children => true
        action :create
      end
    end
  end
end

action_class do
  include CPE::WindowsChromeHelpers
end
