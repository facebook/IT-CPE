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

  if node['cpe_chrome']['_use_new_windows_provider']
    # Set all the keys we care about. If there's any mismatch of data, just
    # delete the entire key and re-establish it, because we can't atomically
    # change individual subkeys in one single registry_key resource invocation
    reg_settings = set_reg_settings(node)
    doomed_policies = policies_to_remove(node['cpe_chrome']['_use_reg_file'])

    if node['cpe_chrome']['_use_reg_file']
      reg_file_path = ::File.join(Chef::Config[:file_cache_path], 'chrome.reg')

      policy_settings = gen_reg_file_settings(
        doomed_policies, reg_settings
      )
      template reg_file_path do # ~FB031
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
    else
      doomed_policies.each do |policy, curr_value|
        if policy.is_a?(WindowsChromeFlatSetting)
          registry_key policy.registry_location do
            values curr_value
            action :delete
          end
        elsif policy.is_a?(WindowsChromeIterableSetting)
          registry_key policy.registry_location do
            recursive true
            action :delete_key
          end
        end
      end

      reg_settings.each do |setting|
        registry_key setting.registry_location do
          values setting.to_chef_reg_provider
          recursive true
          action :create
        end
      end
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
  else
    # ExtensionSettings has a "dictionary" format and each key must be stored
    # as a separate sub key inside the ExtensionSettings registry setting
    # Ref: https://cloud.google.com/docs/chrome-enterprise/policies/?policy=ExtensionSettings
    extension_settings_key = 'ExtensionSettings'.freeze
    reg_settings = []
    node['cpe_chrome']['profile'].each do |setting_key, setting_value|
      next if setting_value.nil?
      if setting_value.is_a?(Hash)
        next if setting_value.empty?
      end
      # ExtensionSettings must have a different registry structure
      if (setting_value.is_a? Hash) && (setting_key == extension_settings_key)
        setting_value.each do |extension_key, extension_value|
          if extension_value.is_a? Hash
            extension_value.each do |inner_key, inner_value|
              reg_settings <<
                WindowsChromeSetting.new(
                  { inner_key => inner_value },
                  "#{setting_key}\\#{extension_key}",
                )
            end
          else
            reg_settings <<
              WindowsChromeSetting.new(
                { extension_key => extension_value },
                setting_key.to_s,
              )
          end
        end
      else
        reconstruct_setting = { setting_key => setting_value }
        reg_settings << WindowsChromeSetting.new(reconstruct_setting)
      end
    end

    # Set all the keys we care about. If there's any mismatch of data, just
    # delete the entire key and re-establish it, because we can't atomically
    # change individual subkeys in one single registry_key resource invocation
    reg_settings.uniq.each do |setting|
      next if setting.fullpath.empty?
      new_values = setting.to_chef_reg_provider
      current_values = nil
      if registry_key_exists?(setting.fullpath)
        current_values = registry_get_values(setting.fullpath)
      end
      # Make sure we're comparing apples to apples, as registry_get_values()
      # always returns an array, even if the data itself only contains one value
      unless new_values.is_a?(Array)
        new_values = [new_values]
      end
      if new_values.empty? || new_values != current_values
        Chef::Log.debug(
          "cpe_chrome: Deleting #{setting.fullpath} because of mismatch",
        )
        Chef::Log.debug("cpe_chrome: Old values: #{current_values}")
        Chef::Log.debug("cpe_chrome: New values: #{new_values}")
        registry_key setting.fullpath do
          recursive true
          action :delete_key
        end
      end
      registry_key setting.fullpath do
        not_if { new_values.empty? }
        values new_values
        recursive true
        action :create
      end
    end

    extprefs = node['cpe_chrome']['extension_profile']
    unless extprefs.empty? || extprefs.nil?
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
        registry_key "#{CPE::ChromeManagement.chrome_reg_3rd_party_ext_root}\\#{k}\\policy" do
          values ext_values
          recursive true
          action :create
        end
      end
    end

    # Look at all the subkeys total of the root Chrome extension key.
    all_chrome_ext_keys = []
    extension_profile = node['cpe_chrome']['extension_profile']
    if registry_key_exists?(CPE::ChromeManagement.chrome_reg_3rd_party_ext_root) &&
      registry_has_subkeys?(CPE::ChromeManagement.chrome_reg_3rd_party_ext_root)
      all_chrome_ext_keys =
        registry_get_subkeys(CPE::ChromeManagement.chrome_reg_3rd_party_ext_root)
    end
    # This variable should be a superset (or a match) to the list of keys
    # in the node attribute.
    extra_chrome_ext_keys = all_chrome_ext_keys - extension_profile.keys
    Chef::Log.debug("#{cookbook_name}: Extra keys: #{extra_chrome_ext_keys}")
    extra_chrome_ext_keys.each do |rip_key|
      registry_key "#{CPE::ChromeManagement.chrome_reg_3rd_party_ext_root}\\#{rip_key}" do
        action :delete_key
        recursive true
      end
    end

    # Hack - if any extension profile configs, don't delete the root key
    chrome_profile = node['cpe_chrome']['profile'].to_h
    if extension_profile.values.any?
      chrome_profile['3rdparty'] = nil
    end

    # Look at all the subkeys total of the root Chrome key.
    all_chrome_keys = []
    if registry_key_exists?(CPE::ChromeManagement.chrome_reg_root) &&
      registry_has_subkeys?(CPE::ChromeManagement.chrome_reg_root)
      all_chrome_keys =
        registry_get_subkeys(CPE::ChromeManagement.chrome_reg_root)
    end
    # This variable should be a superset (or a match) to the list of keys
    # in the node attribute.
    extra_chrome_keys = all_chrome_keys - chrome_profile.keys
    extra_chrome_keys.each do |rip_key|
      registry_key "#{CPE::ChromeManagement.chrome_reg_root}\\#{rip_key}" do
        action :delete_key
        recursive true
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
        directory dir do # ~FB024
          rights :read, 'Everyone', :applies_to_children => true
          rights :read_execute, 'Users', :applies_to_children => true
          rights :full_control, ['Administrators', 'SYSTEM'],
                 :applies_to_children => true
          action :create
        end
      end

      file "create-#{pref_path}" do # ~FB023
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
